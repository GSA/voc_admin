require 'resque/failure/backtrace'

Resque::Failure.backend = Resque::Failure::Backtrace
