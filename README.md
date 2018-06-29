# I Would Have Spent

Application for learning from your YNAB transaction history.

## Local Development

require elm 0.18 and npm to run. To run:

1. install a `create-elm-app` for development environment management.

```
npm install create-elm-app -g
```

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

Your browser should now open to up to a working version of the site.


