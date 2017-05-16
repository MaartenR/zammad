# Service Planet Fork

This is a fork of the original Zammad repository and adds the following 
changes/features:

- E-mails can be directly relayed into Zammad via smtp by setting up an e-mail 
account and selecting smtp for inbound. The smtp server is started 
automatically.

- Some stability issues with the scheduler and/or delayed jobs arose every now
and then. Errors that occurred killed the entire background thread on which 
these jobs were running, thereby preventing jobs that had nothing to do with 
this error from executing. This made the whole system choke. The change that 
introduced made schedulers that failed to start record the cause of this 
failure after which the system no longer attempted to start this scheduler. An
exception is no longer raised making it possible for other jobs to continue 
running. See T621.
