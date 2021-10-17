# VHS Test Template

By Using the above template, i have built the application and tried executing the application.

1. POST `/blocknative/transaction/:transaction_id` 
   - This end point is used to submit a pending transaction to the vhs application. Once confirmation of transaction, a Slack message wil pop-up.
   
2. POST `/blocknative/transactions' --> With Json %{"transactions_id" => []} 
  - This endpoint is similar to the above, But it accepts multiple transaction
 
 
 The Solution to the problem.
 - On submitting the transactions through the above endpoint, vhs_test would trigger a HTTP call to blocknative to watch the transaction.
 - And Vhs store this transaction information in ETS internal storage
 - A WebHook is enabled on blocknative to trigger real-time notifications. I have used ngrok as tunneling library, which allow to server webhooks on localhost
- On Confirmation through webhook, the statue message is pushed to Slack
- If there is no confirmation in next 2 minutes, the vhs_test would notify on Slack channel, the status of transaction.

- I am not sure, of unwatch a transaction(there is no reference of diocumentation for unwatch). Due to this, we can't unwatch the transaction post confirmation. This leads to a huge transactions count. 
