brew install ruby-install chruby
ruby-install ruby 3.1.2
chruby 3.1.2
rails new ruby-rails-starter -T -d postgresql
cd ruby-rails-starter

bin/bundle add rspec-rails --version "~> 6.0.0.rc1" --group "development, test"
bin/rails generate rspec:install

bin/bundle add packwerk --version "~> 2.2.0"
bin/bundle add pocky --version "~> 2.9" --group "development, test"
bin/bundle exec packwerk init

sed -i '' '25i\
    config.paths.add "packages", glob: "{*/app,*/app/concerns}", eager_load: true' config/application.rb

sed -i '' '2i\
  append_view_path(Dir.glob(Rails.root.join("packages/*/app/views")))
' app/controllers/application_controller.rb

mkdir -p packages/data_collector/{app,spec} packages/data_analyzer/{app,spec} packages/rails_support/app
echo "enforce_dependencies: true\nenforce_privacy: false\ndependencies:\n  - packages/rails_support" > packages/data_collector/package.yml
echo "enforce_dependencies: true\nenforce_privacy: false\ndependencies:\n  - packages/rails_support" > packages/data_analyzer/package.yml
echo "enforce_dependencies: true\nenforce_privacy: false" > packages/rails_support/package.yml

echo packwerk.png >> .gitignore

mv app/controllers/application_controller.rb packages/rails_support/app/
mv app/jobs/application_job.rb packages/rails_support/app/
mv app/mailers/application_mailer.rb packages/rails_support/app/
mv app/models/application_record.rb packages/rails_support/app/
mv app/channels/application_cable packages/rails_support/app/
rm -rf app/controllers app/jobs app/mailers app/models app/channels app/helpers

bin/rake pocky:generate && open packwerk.png
bin/bundle exec packwerk validate

echo "--pattern packages/*/spec/**/*_spec.rb\n--pattern spec/**/*_spec.rb" >> .rspec
bin/bundle exec rspec
