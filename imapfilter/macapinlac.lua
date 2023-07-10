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

local password = get_imap_password("MACAPINLAC_IMAP_PASSWORD",
                                   ".ritchie@macapinlac.com",
                                   "email/macapinlac.com")

local account = IMAP {
    server = 'imap.gmail.com',
    username = 'ritchie@macapinlac.com',
    password = password,
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
                      account.INBOX:contain_to('ritchie+newsletter@macapinlac.com') +
                      account.INBOX:contain_to('ritchie+newsletters@macapinlac.com') +
                      account.INBOX:contain_from('no-reply@marketing.zerolongevity.com') +
                      account.INBOX:contain_from('carl@carlpullein.com') +
                      account.INBOX:contain_from('crew@morningbrew.com')
                    )
newsletters:move_messages(account['zzz - Automated/Newsletters'])

-- Homelab: Yukari
local yukari = account.INBOX:contain_subject('[YUKARI] A new DSM update has been detected on yukari') +
               account.INBOX:contain_subject('[YUKARI] Packages on yukari are out-of-date')
yukari:move_messages(account['zzz - Automation/Homelab - Notifications'])

-- BC Hydro and Fortis
local bchydro = account.INBOX:is_seen() *
                account.INBOX:contain_from('notifications@bchydro.com')
bchydro:move_messages(account['zzz - 3236 East 6th/BC Hydro'])

local fortis = account.INBOX:is_seen() *
               account.INBOX:contain_from('gas.customerservice@fortisbc.com')
fortis:move_messages(account['zzz - Automation/Download attachments'])

-- TD Canada trust
local td  = account.INBOX:is_seen() *
            account.INBOX:contain_from('noreply@td.com')
td:move_messages(account['zzz - 3236 East 6th/TD Canada Trust'])

-- ESS School announcements
-- Move after they've been read
local ess_school_announcements = account.INBOX:is_seen() *
                                 (
                                   account.INBOX:contain_from('principal@ess.vancouver.bc.ca') +
                                   account.INBOX:contain_from('admin@ess.vancouver.bc.ca')
                                 ) * (
                                   --	ess_parents@ess.vancouver.bc.ca
                                   account.INBOX:contain_bcc('ess_parents@ess.vancouver.bc.ca')
                                 )
ess_school_announcements:move_messages(account['ESS/School Announcements'])

-- Grade 7 announcements
-- Move after they've been read
local ess_grade7  = account.INBOX:is_seen() *
                    account.INBOX:contain_from('johnson@ess.vancouver.bc.ca') * (
                      -- grade7_parents@ess.vancouver.bc.ca
                      account.INBOX:contain_bcc('grade7_parents@ess.vancouver.bc.ca')
                    )
ess_grade7:move_messages(account['ESS/Classroom News/Grade 7 - Chyler'])

-- Not relevant ESS stuff
local ess_sports = account.INBOX:contain_from('douo@ess.vancouver.bc.ca')
ess_sports:move_messages(account['ESS/Sports'])

-- shopping / promotions
local shopping = account.INBOX:contain_to('ritchie+promotions@macapinlac.com') +
                 account.INBOX:contain_to('ritchie+promotion@macapinlac.com') +
                 -- Ollie Quinn
                 account.INBOX:contain_from('latest@email.oqspecs.com') + (
                   account.INBOX:contain_to('family@macapinlac.com') +
                   account.INBOX:contain_subject('We found price drops for an item you Droplisted')
                 )
shopping:move_messages(account['zzz - Automated/Shopping'])

-- Village at Walker Lakes related
-- Pagnihotri@kdmmgmt.ca
local villagewl = account.INBOX:contain_from('Pagnihotri@kdmmgmt.ca')
villagewl:move_messages(account['zzz - Village at Walker Lakes/KDM Management'])

-- New home warranty
local anhwp = account.INBOX:contain_from('communications@anhwp.com')
anhwp:move_messages(account['zzz - Village at Walker Lakes/Alberta New Home Warranty'])

-- random banking stuff (sometimes important)
local banking = account.INBOX:contain_from('NO_REPLY@communications.bpi.com.ph')
banking:move_messages(account['zzz - Automated/Banking'])

-- allowance emails
local simplii = account.INBOX:contain_from('notify@payments.interac.ca') * (
                  account.INBOX:contain_subject('INTERAC e-Transfer: Your money transfer to MACKENZEE CHARL MACAPINLAC was deposited.') +
                  account.INBOX:contain_subject('INTERAC e-Transfer: Your money transfer to CHYLER ROWAN C MACAPINLAC was deposited.')
                )
simplii:move_messages(account['Receipts and Invoices'])

-- Jobs!
local jobs        = account.INBOX:contain_from('jobs-noreply@linkedin.com') +
                    account.INBOX:contain_from('hello@creativeclass.co') +
                    account.INBOX:contain_to('ritchie+jobs@macapinlac.com')
jobs:move_messages(account['zzz - Automated/Jobs'])

-- RitchiePlex
ritchieplex = account.INBOX:contain_from('ritchieplex@macapinlac.network')
ritchieplex:move_messages(account['zzz - Automated/RitchiePlex'])


-- Ugh, just delete it!
ugh = account.INBOX:contain_from('e-service@acmsmail.china-airlines.com')
ugh:delete_messages()
