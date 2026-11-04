# frozen_string_literal: true

SimpleCov.configure do
  enable_coverage :branch
  coverage :line, minimum: 99.84
  coverage :branch, minimum: 96.47, ignore: :implicit_else
  skip ['/spec/', '/vendor/bundle/']
end
