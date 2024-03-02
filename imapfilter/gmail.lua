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

local password = get_imap_password("GMAIL_IMAP_PASSWORD",
                                   ".rsmacapinlac@gmail.com",
                                   "email/gmail.com")

local account = IMAP {
    server = 'imap.gmail.com',
    username = 'rsmacapinlac@gmail.com',
    password = 'mtlp doag fmgv tuks',
    ssl = "tls1"
}

account.INBOX:check_status()

------------------
----  Rules     --
------------------

-- https://syshero.org/2016-06-19-imapfilter-cleaning-up-your-mailbox-and/
-- remove meeting invites older than 90 days
local cal_delete_older  = 90
local old_messages = account["[Gmail]/All Mail"]:contain_field("sender", "calendar-notification@google.com") * account["[Gmail]/All Mail"]:is_older(cal_delete_older)
old_messages:move_messages(account["[Gmail]/Trash"])

-- Read Newsletters rule
-- Only move newsletters that have been read
local newsletters = account.INBOX:is_seen() * (
                      account.INBOX:contain_to('rsmacapinlac+newsletter@gmail.com') +
                      account.INBOX:contain_to('rsmacapinlac+newsletters@gmail.com') +
                      account.INBOX:contain_from('icbc@enews.icbc.com') +
                      account.INBOX:contain_from('info@enews.icbc.com')
                    )
newsletters:move_messages(account['zzz - Saved Emails/Newsletters'])


-- Google notifications
local notifications = account.INBOX:contain_from('no-reply@accounts.google.com')
notifications:move_messages(account['Notifications/Google'])
