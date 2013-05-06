$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

def require_tree(path)
  path = File.expand_path(path, File.dirname(__FILE__))

  files = Dir.glob(File.join(path, '**/*.rb'))
  raise "Directory '#{path}' is empty" unless files.length > 0

  files.each { |file| puts "  require #{file}"; require file }
end

require_tree '../lib'