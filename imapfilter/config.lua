----------------
--  Accounts  --
----------------
require "os"
package.path = package.path .. ';' .. os.getenv("HOME") .. '/.imapfilter/?.lua'

-- Utility function to get IMAP password from file
function get_imap_password_from(file)
  local home = os.getenv("HOME")
  local file = home .. "/" .. file
  local str = io.open(file):read()
  return str;
end

-- utility to retrieve password from either an environment variable or file
function get_imap_password(envvar, file)
  password = os.getenv(envvar)
  if password == nil then
    password = get_imap_password_from(file)
  end
  return password;
end

require("macapinlac")
require("boogienet")
