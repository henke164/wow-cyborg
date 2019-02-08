function GetColorFromNumber(number)
  if number == 0 then
    return 0, 0, 0;
  end
  if number == 1 then
    return 0, 0, 0.5;
  end
  if number == 2 then
    return 0, 0, 1;
  end
  if number == 3 then
    return 0, 0.5, 0;
  end
  if number == 4 then
    return 0, 1, 0;
  end
  if number == 5 then
    return 0.5, 0, 0;
  end
  if number == 6 then
    return 1, 0, 0;
  end
  if number == 7 then
    return 0, 0.5, 1;
  end
  if number == 8 then
    return 0, 1, 1;
  end
  if number == 9 then
    return 0.5, 0, 1;
  end
  return 1, 1, 1;
end