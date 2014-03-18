class Voltdb < Settingslogic
  source "#{Rails.root}/config/voltdb.yml"
  namespace Rails.env

  def self.voltdb_executable_path
    if self.bin_path
      File.expand_path File.join(self.bin_path, "voltdb")
    else
      "voltdb"
    end
  end

  def self.log_file
    File.expand_path File.join(Voltdb.output_dir, "#{Voltdb.host}_#{Voltdb.port}.out")
  end

  def self.pid_file
    File.expand_path File.join(Voltdb.output_dir, "#{Voltdb.host}_#{Voltdb.port}.pid")
  end

end
