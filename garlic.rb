# typical rspec garlic configuration

garlic do
  # this plugin
  repo "subit", :path => '.'
  
  # other repos
  repo "rails", :url => "git://github.com/rails/rails"
  repo "rspec", :url => "git://github.com/dchelimsky/rspec"
  repo "rspec-rails", :url => "git://github.com/dchelimsky/rspec-rails"
  
  # target railses
  ['2-3-stable', '2-2-stable', '2-1-stable'].each do |rails|
    
    # declare how to prepare, and run each CI target
    target "Rails: #{rails}", :branch => "origin/#{rails}" do
      prepare do
        plugin "subit", :clone => true # so we can work in targets
        plugin "rspec"
        plugin "rspec-rails" do
          `script/generate rspec -f`
        end
      end
    
      run do
        cd "vendor/plugins/subit" do
          sh "rake rcov"
        end
      end
    end
  end
end
