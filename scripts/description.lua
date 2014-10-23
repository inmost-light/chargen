local descriptions = {}

function add_desc(topic)
  return function(body)
    descriptions[string.lower(topic)] = body
  end
end

add_desc 'Class' [[Classes represent chosen professions taken by characters and some other creatures. Classes give a host of bonuses and allow characters to take actions that they otherwise could not, such as casting spells or changing shape. As a creature gains levels in a given class, it gains new, more powerful abilities. Most PCs gain levels in the core classes or prestige classes, since these are the most powerful. Most NPCs gain levels in NPC Classes, which are less powerful.]]

add_desc 'Level' [[A character's level represents his overall ability and power. There are three types of levels. Class level is the number of levels of a specific class possessed by a character. Character level is the sum of all of the levels possessed by a character in all of his classes. In addition, spells have a level associated with them numbered from 0 to 9. This level indicates the general power of the spell. As a spellcaster gains levels, he learns to cast spells of a higher level.]]

add_desc 'XP' [[As a character overcomes challenges, defeats monsters, and completes quests, he gains experience points. These points accumulate over time, and when they reach or surpass a specific value, the character gains a level.]]

add_desc 'HP' [[Hit points are an abstraction signifying how robust and healthy a creature is at the current moment. To determine a creature's hit points, roll the dice indicated by its Hit Dice. A creature gains maximum hit points if its first Hit Die roll is for a character class level. Creatures whose first Hit Die comes from an NPC class or from his race roll their first Hit Die normally. Wounds subtract hit points, while healing (both natural and magical) restores hit points. Some abilities and spells grant temporary hit points that disappear after a specific duration. When a creature's hit points drop below 0, it becomes unconscious. When a creature's hit points reach a negative total equal to its Constitution score, it dies.]]

add_desc 'AC' [[All creatures in the game have an Armor Class. This score represents how hard it is to hit a creature in combat. As with other scores, higher is better. This is the target number enemies need to hit you. Your basic AC is 10 + Dex modifier + armor bonus + shield bonus + spells or magic items that grant an AC bonus.]]

add_desc 'BAB' [[Each creature has a base attack bonus and it represents its skill in combat. As a character gains levels or Hit Dice, his base attack bonus improves. When a creature's base attack bonus reaches +6, +11, or +16, he receives an additional attack in combat when he takes a full-attack action.]]

add_desc 'Saves' [[When a creature is the subject of a dangerous spell or effect, it often receives a saving throw to mitigate the damage or result. Saving throws are passive, meaning that a character does not need to take an action to make a saving throw—they are made automatically. There are three types of saving throws: Fortitude (used to resist poisons, diseases, and other bodily ailments), Reflex (used to avoid effects that target an entire area, such as fireball), and Will (used to resist mental attacks and spells).]]

add_desc 'Fortitude' [[These saves measure your ability to stand up to physical punishment or attacks against your vitality and health. Apply your Constitution modifier to your Fortitude saving throws.]]

add_desc 'Reflex' [[These saves test your ability to dodge area attacks and unexpected situations. Apply your Dexterity modifier to your Reflex saving throws.]]

add_desc 'Will' [[These saves reflect your resistance to mental influence as well as many magical effects. Apply your Wisdom modifier to your Will saving throws.]]

return {
  data = descriptions,
  add_desc = add_desc
}
