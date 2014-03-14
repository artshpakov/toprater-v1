class Voltdb < Settingslogic
  source "#{Rails.root}/config/voltdb.yml"
  namespace Rails.env
end
