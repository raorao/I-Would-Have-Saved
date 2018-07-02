# I Would Have Saved

Application for learning from your YNAB transaction history.

## Local Development

Requires [npm](https://www.npmjs.com/) to run. To get a server running locally:

1. install `create-elm-app` for development environment management.

```
npm install create-elm-app -g
```

Note: this will install elm if you have yet do to so.

2. create a `.env` file

```
cp .env.example .env
```

3. replace necessary `.env` values with values from the YNAB developer console.

You can access the console at `https://app.youneedabudget.com/oauth/applications`

4. start the server

```
elm-app start
```

Your browser should now open to up to a working version of the site. You will be prompted to connect to YNAB. authorize the application, and copy `access_token=<<token>>` value from the URL.

5. visit `/home#access_token=<<token>>`

You should now see a working version of the site.

## Deployment

Deployments are handled through GitHub -- currently, netlify will deploy a new
version of the site whenever the `deploy` branch is updated remotely. see `./deploy.sh --help` for further instructions.
