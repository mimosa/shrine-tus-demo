web: bundle exec puma -C config/puma.rb

job: bundle exec sidekiq -r ./*.rb  -C config/sidekiq.yml

# https://github.com/tus/tusd/releases/download/0.13.0/tusd_darwin_amd64.zip
tus: tusd -host localhost -port $TUSD_PORT -behind-proxy -hooks-http http://localhost:$PUMA_PORT/write >> log/$RACK_ENV.log

# https://github.com/anycable/anycable-go/releases/download/v0.6.2/anycable-go-v0.6.2-darwin-amd64
# brew install anycable-go
rpc: bundle exec anycable -r ./config/lite_cable.rb --server-command "anycable-go -redis_url=$ANYCABLE_REDIS_URL"
