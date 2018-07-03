import './main.css';
import './elm-datepicker.css'

import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

Main.embed(document.getElementById('root'), {
  ynab_client_id: process.env.ELM_APP_YNAB_CLIENT_ID,
  ynab_redirect_uri: process.env.ELM_APP_YNAB_REDIRECT_URI
});

registerServiceWorker();
