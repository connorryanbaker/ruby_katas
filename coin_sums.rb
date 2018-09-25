def count_change(amount)
  cc(amount, 8)
end

def cc(amount, kinds)
  return 1 if amount == 0
  return 0 if amount < 0 || kinds == 0
  elim = amount - first_denomination(kinds)
  p [elim, amount, kinds]
  cc(amount, kinds - 1) + cc(elim, kinds)
end

def first_denomination(kinds)
  if kinds == 1
    return 1
  elsif kinds == 2
    return 2
  elsif kinds == 3
    return 5
  elsif kinds == 4
    return 10
  elsif kinds == 5
    return 20
  elsif kinds == 6
    return 50
  elsif kinds == 7
    return 100
  elsif kinds == 8
    return 200
  end
end

p count_change(200)
