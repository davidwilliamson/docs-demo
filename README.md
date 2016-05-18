# docs-demo
Serve up static HTML files using github OAUTH to control access. 

##Host set up
* Install docker and docker-compose
  * [Docker for mac](https://docs.docker.com/engine/installation/mac/)
  * [docker on ubuntu](https://docs.docker.com/engine/installation/linux/ubuntulinux/)
  * [docker on cloud provider](https://docs.docker.com/engine/installation/cloud/overview/)
  * [Install compose](https://docs.docker.com/compose/install/)

* Create server certificates (poor man's method is to use a self-signed cert)
  [How to create a self-signed cert on Stack overflow](http://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl)
`openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 30`
* Put the certificate files in `./nginx/creds` (e.g., `cert.pem` and `key.pem`)

##App set up
* Create an organization on github [https://github.com/settings/organizations]
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
##usage
* Set required environment variables
`export NGINX_SERVER_NAME=<host-where-this-is-running>`
`export OAUTH2_PROXY_CLIENT_ID=<From-GitHub-App>`
`export OAUTH2_PROXY_CLIENT_SECRET=<Corresponding-Secret-From-GitHub-App>`

Now, stand up the stack
`docker-compose up`

Then point your browser to the site where this is hosted:
`https://<host-where-this-is-running>`

Click the GitHub button to authenticate. In github, allow this application. You will then be redirected to this web site's content.

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
