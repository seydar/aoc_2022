def diamond(dist)
  timantti = []
  (0..dist).each do |i|
    (0..(dist - i)).each do |j|
      timantti << [i, j]
      timantti << [-i, -j] if i != 0 && j != 0
      timantti << [-i, j]  if i != 0
      timantti << [i, -j]  if j != 0
    end
  end

  timantti
end

def border(dist)
  timantti = []
  dist += 1
  (0..dist).each do |i|
    j = dist - i
    timantti << [i, j]
    timantti << [-i, -j] if i != 0 && j != 0
    timantti << [-i, j]  if i != 0
    timantti << [i, -j]  if j != 0
  end

  timantti
end

def partial_diamond(dist, row)
  timantti = []
  (0..dist - row.abs).each do |i|
    timantti << [i, row]
    timantti << [-i, row] if i != 0
  end

  timantti
end

vals = diamond(ARGV[0].to_i).sort_by {|x, y| x }
pp vals

pp border(ARGV[0].to_i).sort_by {|x, y| x }

