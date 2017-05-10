# Service Planet Fork

This is a fork of the original Zammad repository and adds the following 
changes/features:

- E-mails can be directly relayed into Zammad via smtp by setting up an e-mail 
account and selecting smtp for inbound. The smtp server is started 
automatically.

Planned changes:

- Some stability issues with the scheduler and/or delayed jobs arise every now
and then. This needs to be fixed see T621.