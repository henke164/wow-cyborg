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

function GetColorFromButton(button)
  if button == "F" then
    return 1,0,0;
  end
  if button == "SHIFT" then
    return 0,1,0;
  end
  if button == "ALT" then
    return 1,1,0;
  end
  if button == "CTRL" then
    return 0,0,1;
  end

  return 1,1,1;
end

function GetNumbersFromLetter(button)
  if button == "A" then
    return 0, 1;
  end
  if button == "B" then
    return 0, 2;
  end
  if button == "C" then
    return 0, 3;
  end
  if button == "D" then
    return 0, 4;
  end
  if button == "E" then
    return 0, 5;
  end
  if button == "F" then
    return 0, 6;
  end
  if button == "G" then
    return 0, 7;
  end
  if button == "H" then
    return 0, 8;
  end
  if button == "I" then
    return 0, 9;
  end
  if button == "J" then
    return 1, 0;
  end
  if button == "K" then
    return 1, 1;
  end
  if button == "L" then
    return 1, 2;
  end
  if button == "M" then
    return 1, 3;
  end
  if button == "N" then
    return 1, 4;
  end
  if button == "O" then
    return 1, 5;
  end
  if button == "P" then
    return 1, 6;
  end
  if button == "Q" then
    return 1, 7;
  end
  if button == "R" then
    return 1, 8;
  end
  if button == "S" then
    return 1, 9;
  end
  if button == "T" then
    return 2, 0;
  end
  if button == "U" then
    return 2, 1;
  end
  if button == "V" then
    return 2, 2;
  end
  if button == "W" then
    return 2, 3;
  end
  if button == "X" then
    return 2, 4;
  end
  if button == "Y" then
    return 2, 5;
  end
  if button == "Z" then
    return 2, 6;
  end
end