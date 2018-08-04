web: bundle exec puma -C config/puma.rb
job: bundle exec sidekiq -r ./*.rb  -C config/sidekiq.yml
tus: tusd -host localhost -port $TUSD_PORT -behind-proxy >> log/$RACK_ENV.log
rpc: bundle exec ./anycable
ws:  sleep 2 && anycable-go -addr=localhost:9293 -redis=$ANYCABLE_REDIS_URL
