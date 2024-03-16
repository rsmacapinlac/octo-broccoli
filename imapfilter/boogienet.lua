---------------
----  Options  --
-----------------
--
options.timeout = 120
options.subscribe = true
options.create = true
options.expunge = true

------------------
----  Accounts  --
------------------

local password = get_imap_password("BOOGIENET_IMAP_PASSWORD",
                                   ".rsmacapinlac@boogienet.com",
                                   "email/boogienet.com")
local account = IMAP {
    server = 'mail.hostedemail.com',
    username = 'rsmacapinlac@boogienet.com',
    -- for some reason, locally, the pipe_from doesn't work
    -- pass email/boogienet.com > ~/.rsmacapinlac@boogienet.com
    password = password,
    ssl = "tls1"
}

account.INBOX:check_status()

------------------
----  Rules     --
------------------

local newsletters = account.INBOX:is_seen() * (
                      account.INBOX:contain_from('community@invoiceninja.com')
                    )
newsletters:move_messages(account['zzz - Automated/Newsletters'])


local whois = account.INBOX:contain_subject('WHOIS Data Confirmation for')
whois:move_messages(account['zzz - Automated.WhoIs'])

-- Hosting Alerts
alerts = account.INBOX:contain_from('wordpress@alifewithgusto.com') +
         account.INBOX:contain_from('wordpress@boogienet.com')

alerts:move_messages(account['zzz - Automated.Hosting Plugin Alerts'])


-- Move for Monthly N8N Automations
local monthly  = account.INBOX:contain_from('noreply@opensrs.email') +
                 (
                   account.INBOX:contain_from('noreply@opensrs.com') *
                   account.INBOX:contain_subject('OpenSRS Email Services Invoice')
                 )
monthly:unmark_seen()
monthly:move_messages(account['zzz - Automations.MonthlyReport'])

-- Move for N8N Automations
local weekly = account.INBOX:contain_from('support@boogienet.com') *
               account.INBOX:contain_subject('Weekly report for All Websites')

weekly:move_messages(account['zzz - Automations.Weekly'])

-- delete successful InfiniteWP message
local infinitewp_success = account.INBOX:contain_from('gwen@boogienet.com') *
                           account.INBOX:contain_subject('InfiniteWP | Everything is up to date.')
infinitewp_success:delete_messages()

-- move this message into the automations folder for n8n
local infinitewp_updates = account.INBOX:contain_from('gwen@boogienet.com') *
                           account.INBOX:contain_subject('InfiniteWP | New Updates Available.')
infinitewp_updates:move_messages(account['zzz - Automations.InfiniteWP-Updates'])


-- Ugh, just delete it!
local ugh = account.INBOX:contain_from('boogiene@rcentral503.webserversystems.com') *
            account.INBOX:contain_subject('Cron')
ugh:delete_messages()
