Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 10.hours
Delayed::Worker.delay_jobs = !Rails.env.test?