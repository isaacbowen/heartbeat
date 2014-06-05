metrics = [
  # required
  ['Happiness', 'Yep. How are you feeling?', true],
  ['Interactions', 'Think about everyone you worked with this week. How\'d everything go?', true],
  ['Optimism', 'How do you feel about the future?', true],

  # not required
  ['Community', 'Build team unity and alignment by consistently connecting, sharing, and supporting.', false],
  ['Shared Ownership', 'Practice commitment and accountability as individuals and groups, in service of a shared mission.', false],
  ['Craftsmanship', 'Be constantly deliberate in the quality of your product, of your environment, and of your community.', false],
  ['Communication and Awareness', 'Proactively share and seek state, horizontally and vertically, to build solidarity and trust.', false],
  ['Practicality vs Idealism', 'Choose the right solution given constraints, knowing when to push back.', false],
]

metrics.each_with_index do |args, i|
  name, description, required = args
  Metric.where(name: name).first_or_create(order: i, description: description, required: required)
end
