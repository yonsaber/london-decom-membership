if Rails.env.local?
  desc 'Run rubocop - configure in .rubocop.yml'
  task rubocop: :environment do
    require 'rubocop/rake_task'

    RuboCop::RakeTask.new(:rubocop) do |t|
      t.options = ['--display-cop-names']
    end
  end
end
