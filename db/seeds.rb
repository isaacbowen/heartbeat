metrics = [
  ['Community', 'Build team unity and alignment by consistently connecting, sharing, and supporting.'],
  ['Shared Ownership', 'Practice commitment and accountability as individuals and groups, in service of a shared mission.'],
  ['Craftsmanship', 'Be constantly deliberate in the quality of your product, of your environment, and of your community.'],
  ['Communication and Awareness', 'Proactively share and seek state, horizontally and vertically, to build solidarity and trust.'],
  ['Balanced Pragmatism', 'Weigh quality versus resources, knowing when to force an exception.'],
]

metrics.each_with_index do |args, i|
  name, description = args
  Metric.where(name: name).first_or_create(order: i, description: description)
end
