if ActiveRecord::Base.connection.adapter_name.downcase.match /oracle/
  ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter.class_eval do

    # http://wiki.github.com/rsim/oracle-enhanced/usage

    self.default_sequence_start_value = "1 NOCACHE INCREMENT BY 1"
    self.emulate_integers_by_column_name = true
    self.emulate_booleans_from_strings = true
  end
end