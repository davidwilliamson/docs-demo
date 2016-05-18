# docs-demo
Serve up static HTML files using github OAUTH to control access. 

Uses [nginx](http://nginx.org/) to terminate the SSL connections and to serve up pages once the user has authenticated. Uses [oauth2_proxy](https://github.com/bitly/oauth2_proxy) to perform oauth authentication with github, allowing us to restrict access to the web pages.

Based on [this blog](http://developers.canal-plus.com/blog/2015/11/07/install-nginx-reverse-proxy-with-github-oauth2/), with additional functionality:
* Runs in [docker](www.docker.com) containers
* Allows HTTPS (as opposed to HTTP) connection from browser.

##Host set up
* Install docker and docker-compose
  * [Docker for mac](https://docs.docker.com/engine/installation/mac/)
  * [docker on ubuntu](https://docs.docker.com/engine/installation/linux/ubuntulinux/)
  * [docker on cloud provider](https://docs.docker.com/engine/installation/cloud/overview/)
  * [Install compose](https://docs.docker.com/compose/install/)

* Create server certificates 
  * Poor man's method is to use a self-signed cert: [How to create a self-signed cert on Stack overflow](http://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl)
    * `openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 30`
    * `chmod 400 key.pem`
* Put the certificate files in `./nginx/creds` (e.g., `cert.pem` and `key.pem`)

##App set up
* Create an organization on github [https://github.com/settings/organizations]. Invite other GitHub users to your organization. _Everyone in the organization will be able to see the web content_
* (optional) create a team within that organization on github
* Create an Oauth application on github [https://github.com/settings/applications/new]
  * Application name and description are arbitrary
  * For Homepage URL use `https://<host-where-this-is-running>/`
  * For Authorization callback URL, use `https://<host-where-this-is-running>/oauth2/callback`
  * GitHub will provide a client ID and client secret; those are the values for `OAUTH2_PROXY_CLIENT_ID` and `OAUTH2_PROXY_CLIENT_SECRET` in the usage section below.
* Note: the organization must allow access to the OAUTH application; see [https://help.github.com/articles/about-third-party-application-restrictions/] for details.
* Update our config files to reflect the set up:
  * In file `oauth2_proxy/proxy.conf`
    * modify the `github_org` and `github_team` strings to match the organization and team (these are case-sensitive)
    * Change the `cookie_refresh` and `cookie_expire` strings if desired.
* Put the web content in `nginx/content` directory

##Usage
* Set required environment variables
  * `export NGINX_SERVER_NAME=<host-where-this-is-running>`
  * `export OAUTH2_PROXY_CLIENT_ID=<From-GitHub-App>`
  * `export OAUTH2_PROXY_CLIENT_SECRET=<Corresponding-Secret-From-GitHub-App>`

* Now, stand up the stack
  * `docker-compose up`

* Then point your browser to the site where this is hosted:
  * `https://<host-where-this-is-running>`

Note: *If you used a self-signed certificate*, the browser will warn you that the web site is not to be trusted. This is expected, and you should follow the instrucitons to proceed anyway. 

Click the GitHub button to authenticate. In GitHub, click to allow this application. You will then be redirected to this web site's content.

##It doesn't work!
* Make sure all the containers are up: `docker-compose ps`
* Check that the values for `OAUTH2_PROXY_CLIENT_ID` and `OAUTH2_PROXY_CLIENT_SECRET` match the values GitHub is using for the application. Use `env | grep OAUTH2` to determine the values you have in your environment.
* Double check the settings in `oauth2_proxy/proxy.conf`. 
  * Strings are case-sensitive. 
  * You *must* set a value for `github_org` and it must match the GitHub organization name.
  * In addition, you _may_ set a value for `github_team`.
* The GitHub organization must allow access to the OAUTH application; see [https://help.github.com/articles/about-third-party-application-restrictions/] for details
* All errors and warnings from the containers are directed to STDOUT and STDERR. A simple way to log to a file might be:
  * `docker-compose up > server.log 2>&1 &`
  * `tail -f server.log`

##Topology
###Components
[oauth2_proxy](https://github.com/bitly/oauth2_proxy) Handles oauth interaction with GitHub
[nginx](http://nginx.org/) Terminates SSL (HTTPS) traffic and serves up web content.

The basic implementation is described in [this blog](http://developers.canal-plus.com/blog/2015/11/07/install-nginx-reverse-proxy-with-github-oauth2/)

```
          +-------+   +--------------+
client -->| Nginx |-->| oauth2 proxy |
          +-------+   +--------------+
              |              |            +--------+
              |              +----------->| gitHub |
              |                           +--------+
              |
              |       +-----------------+      +-----------+
              +-------| docs web server |------| /foo.html |
                      +-----------------+      +-----------+
```

##Known issues
* Currently using a self-signed certificate for the web server.
