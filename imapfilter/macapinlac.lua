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
                      account.INBOX:contain_from('crew@morningbrew.com') +
                      account.INBOX:contain_from('info@bcaamail.com') +
                      account.INBOX:contain_from('notifications@e-news.wealthsimple.com') +
                      account.INBOX:contain_from('team@news.wakingup.com') +
                      account.INBOX:contain_from('info@enews.icbc.com') +
                      account.INBOX:contain_from('no-reply@myair.resmed.com') +
                      account.INBOX:contain_from('hello@tailscale.com')
                    )
newsletters:move_messages(account['zzz - Automated/Newsletters'])

-- Just move these newsletters, don't wait to read them
newsletters = account.INBOX:contain_from('no-reply@marketing.zerolongevity.com')
newsletters:move_messages(account['zzz - Automated/Newsletters'])

-- Homelab: Yukari
local yukari = account.INBOX:contain_subject('[YUKARI] A new DSM update has been detected on yukari') +
               account.INBOX:contain_subject('[YUKARI] Packages on yukari are out-of-date')
yukari:move_messages(account['zzz - Automation/Homelab - Notifications'])

-- Homelab: Overseer
local overseer = account.INBOX:contain_from('homelab@macapinlac.network') * account.INBOX:contain_subject('Movie Request Now Available')
overseer:move_messages(account['zzz - Automated/RitchiePlex'])

-- Homelab: Bien's bottie
local bottie = account.INBOX:contain_from('ritchie@macapinlac.com') *
               account.INBOX:contain_to('bmatute@rennie.com') *
               account.INBOX:contain_to('ritchie@macapinlac.com')
bottie:move_messages(account['zzz - Automation/Bien\'s Bottie'])

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

-- Notre Dame School announcements
-- Move after they've been read
local nd_school_announcements = account.INBOX:is_seen() *
                                 (
                                   account.INBOX:contain_from('webmaster@myndrs.com') +
                                   account.INBOX:contain_from('scirillo@ndrs.org')
                                 )
nd_school_announcements:move_messages(account['Notre Dame/School Announcements'])

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
                 ) +
                 -- Bailey Nelson
                 account.INBOX:contain_from('hello@baileynelson.com')

shopping:move_messages(account['zzz - Automated/Shopping'])

shopping = account.INBOX:contain_from('EXTRAS@infomail.landmarkcinemas.com')
shopping:move_messages(account['zzz - Automated/Promotions'])

shopping = account.INBOX:contain_from('enews@e.dji.com')
shopping:move_messages(account['zzz - Automated/Promotions'])

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

-- Receipts
local receipts = account.INBOX:contain_from('sunlife@info.sunlife.com') * (
                   account.INBOX:contain_subject('Your recent group benefits claim is processed') +
                   account.INBOX:contain_subject('Your group benefits claim has been received')
                 )
receipts:move_messages(account['zzzz - Saved Emails/Sunlife'])

-- TransUnion Credit Monitoring
local transunion = account.INBOX:contain_from('DoNotReply@transunion.com') * (
                     account.INBOX:contain_subject('Monthly Credit Alert Summary')
                   )
transunion:move_messages(account['zzzz - Saved Emails/TransUnion'])

-- Ugh, just delete it!
ugh = account.INBOX:contain_from('e-service@acmsmail.china-airlines.com')
ugh:delete_messages()
