### Sorting items into optimal gearsets by Item power while filtering by user set amount of Tier pieces and minimum required Fire Resistance

I took crafting the Fire Resist piece very seriously. The issue is - with Tier and other stuff it quickly becomes complicated. And it was bothering me a lot - What’s the real bis for Heat2? Heat3? How does it change if I don’t want to grind Argent Crusader rep? How does it change if I dont want to farm Jujus? Is it better to run Timbermaw Shoulder and/or Kazzak pants if I need to fill once piece with Fine Flarecore gear. Is it more optimal to lose some stats on jewelry or misc stuff like cape? How do I balance 6P and necessary FireRes so I’m minmaxing my damage?

To address these very important questions I made a script in R (I’m in biology so I don’t know any better) which you can feed your shortlist of potential bis pieces, set how much Fire Resist you need, and it will spit out top-10 best gear combinations

It filters out all combinations that don’t have at least 6 Tier pieces, then keeps only gear combinations for which total fire resist >= your input value and then sorts it by item power (ShadowEP in my case - this is stat weight from sixtyupgrades), and keeps top 10).

### Overview and R pipeline:

[https://rskks.github.io/FireRes/Index.html](https://rskks.github.io/FireRes/Index.html)

### Sample table of BiS contender items for Shadow Priest

[https://rskks.github.io/FireRes/Index.html](https://github.com/rskks/FireRes/blob/main/SAMPLE_input_ShadowPriest.xlsx)

### ShinyApp to execute on your own using your table built like a Sample table

[https://rskks.shinyapps.io/FireRes-SOD/](https://rskks.shinyapps.io/FireRes-SOD/)

### Disclaimers

For your own table you need to have the same column names and order, but you can populate them however you want given that:
- Slot - Head, Neck, Shoulder etc, you can write whatever you want at least it's consistent across all items. The resultant table will contain only one of each unique value for slot. You can add as little or as many slots you want, you can also create separate slots for different enchants or consumables;
- Item - item name, can be any string you like.
- ShadowEP - statweight information of the item. You can take it from Sixtyupgrades (you can also make it yourself, get it from simcraft or make it up, I'm not your dad).
- FireRes - fire resistance value
- Tier - whether or not it’s a tier piece, can only be 'Yes' or 'No'

## Warning: if you input too much items, and set a low treshhold for Tier items it might take forever to calculate. As you can see by the Sample table it doesn't contain information for Head, Wrist, Belt, and Boots. That's because these 4 items you are definetly wearing Tier, and because by omitting 4 items we only need to calculate combinations for 4 remaining slots (Sample list is using *only* 31104 possible gear combinations, adding more Tier items to comparison would increase this number exponentionally) 

