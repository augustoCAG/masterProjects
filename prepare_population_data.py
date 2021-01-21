import csv

lists =[]
with open('API_SP.POP.TOTL_DS2_en_csv_v2_1740371.csv') as f:
  reader = csv.reader(f)
  for row in reader:
    if row ==[]:
        pass
    else:
        temp = []
        for element in row:
            if element != '':
                temp.append(element)
        lists.append(temp)

lists = lists[2:] ## removendo as linhas inuteis, pois não contem dados

for sublist in lists:
    del(sublist[1:-1])
    if sublist[-1] == 'SP.POP.TOTL':##excecao para o pais NOT CLASSIFIED
        sublist[-1] = 0
        
    if sublist[0] == "Cote d'Ivoire":
      sublist[0] = "Cote dIvoire"
    if sublist[0] == "Congo, Dem. Rep.":
      sublist[0] = "Dem Rep Congo"
    if sublist[0] == "Congo, Rep.":
      sublist[0] = "Rep Congo"
    if sublist[0] == "Egypt, Arab Rep.":
      sublist[0] = "Egypt"
    if sublist[0] == "Micronesia, Fed. Sts.":
      sublist[0] = "Micronesia"
    if sublist[0] == "Gambia, The":
      sublist[0] = "Gambia"
    if sublist[0] == "Czech Republic":
      sublist[0] = "Czechia"
    if sublist[0] == "Hong Kong SAR, China":
      sublist[0] = "Hong Kong"
    if sublist[0] == "Iran, Islamic Rep.":
      sublist[0] = "Iran"
    if sublist[0] == "Brunei Darussalam":
      sublist[0] = "Brunei"
    if sublist[0] == "Bahamas, The":
      sublist[0] = "Bahamas"
    if sublist[0] == "Macao SAR, China":
      sublist[0] = "Macao"
    if sublist[0] == "Korea, Dem. Peopleâ€™s Rep.":
      sublist[0] = "North Korea"
    if sublist[0] == "Slovak Republic":
      sublist[0] = "Slovakia"
    if sublist[0] == "Venezuela, RB":
      sublist[0] = "Venezuela"
    if sublist[0] == "Yemen, Rep.":
      sublist[0] = "Yemen"
    if sublist[0] == "Russian Federation":
      sublist[0] = "Russia"
    if sublist[0] == "Syrian Arab Republic":
      sublist[0] = "Syria"
    if sublist[0] == "Korea, Rep.":
      sublist[0] = "South Korea"
    if sublist[0] == "St. Kitts and Nevis":
      sublist[0] = "Saint Kitts and Nevis"
    if sublist[0] == "Kyrgyz Republic":
      sublist[0] = "Kyrgyzstan"
    if sublist[0] == "Lao PDR":
      sublist[0] = "Laos"
    if sublist[0] == "St. Vincent and the Grenadines":
      sublist[0] = "Saint Vincent and the Grenadines"
    if sublist[0] == "St. Lucia":
      sublist[0] = "Saint Lucia"
    



del(lists[0])
print(lists)
## criando novo csv formatado
with open('formatted_population_data.csv', 'w', newline='') as write:
  writer = csv.writer(write)
  for item in lists:
     writer.writerow(item)


