----------------
--  Accounts  --
----------------
require "os"
package.path = package.path .. ';' .. os.getenv("HOME") .. '/.imapfilter/?.lua'

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

-- Utility function to get IMAP password from file
function get_imap_password_from(file)
  local file = os.getenv("HOME") .. "/" .. file
  local str = nil
  if file_exists(file) == true then
    str = io.open(file):read()
  end
  return str
end

function get_imap_password_from_pass(path)
  status, password = pipe_from('pass ' .. path)
  return password
end

-- utility to retrieve password from either an environment variable or file
function get_imap_password(envvar, file, pass_path)
  local password = os.getenv(envvar)
  if password == nil then
    password = get_imap_password_from(file)
  end

  if password == nil then
    password = get_imap_password_from_pass(pass_path)
  end
  return password
end

require("macapinlac")
require("boogienet")
