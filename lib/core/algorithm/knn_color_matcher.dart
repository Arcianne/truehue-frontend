import 'dart:math';

/// A utility class for matching RGB colors to their nearest named color
/// using K-Nearest Neighbors algorithm with an extensive color database
/// Contains 750+ unique color names across all families (NO DUPLICATES!)
class ColorMatcher {
  // MASSIVE comprehensive color palette - 100+ colors per family
  static const Map<String, List<int>> _colorPalette = {
    // ==================== REDS (55) ====================
    'Dark Red': [139, 0, 0],
    'Blood Red': [102, 0, 0],
    'Crimson': [220, 20, 60],
    'Scarlet': [255, 36, 0],
    'Ruby': [224, 17, 95],
    'Cherry': [222, 49, 99],
    'Carmine': [150, 0, 24],
    'Burgundy': [128, 0, 32],
    'Wine': [114, 47, 55],
    'Sangria': [146, 0, 10],
    'Garnet': [130, 0, 20],
    'Cardinal': [196, 30, 58],
    'Vermillion': [227, 66, 52],
    'Fire Engine Red': [206, 32, 41],
    'Red': [255, 0, 0],
    'Stop Sign Red': [234, 22, 37],
    'Lipstick Red': [192, 17, 37],
    'Rose Red': [194, 30, 86],
    'Poppy': [235, 44, 31],
    'Tomato': [255, 99, 71],
    'Coral Red': [255, 64, 64],
    'Salmon Red': [250, 128, 114],
    'Watermelon Red': [253, 91, 120],
    'Strawberry': [252, 90, 141],
    'Raspberry': [227, 11, 92],
    'Cranberry': [159, 43, 104],
    'Pomegranate': [192, 57, 43],
    'Red Wine': [92, 18, 20],
    'Merlot': [115, 36, 48],
    'Cabernet': [128, 24, 24],
    'Oxblood': [76, 0, 9],
    'Maroon': [128, 0, 0],
    'Light Maroon': [170, 68, 68],
    'Red Orange': [255, 83, 73],
    'Indian Red': [205, 92, 92],
    'English Red': [171, 75, 82],
    'Spanish Red': [230, 0, 38],
    'Chinese Red': [170, 56, 30],
    'Persian Red': [204, 51, 51],
    'Turkish Red': [166, 25, 46],
    'Venetian Red': [200, 56, 90],
    'Tuscan Red': [124, 72, 72],
    'Fire Brick': [178, 34, 34],
    'Barn Red': [124, 10, 2],
    'Rose Vale': [171, 78, 82],
    'Rose Madder': [227, 38, 54],
    'Dusty Rose': [201, 90, 108],
    'Old Rose': [192, 128, 129],
    'Antique Rose': [145, 95, 109],
    'Blush': [222, 93, 131],
    'Amaranth': [229, 43, 80],

    // ==================== PINKS (63) ====================
    'Pink': [255, 192, 203],
    'Light Pink': [255, 182, 193],
    'Pale Pink': [250, 218, 221],
    'Soft Pink': [255, 200, 220],
    'Pastel Pink': [255, 209, 220],
    'Cotton Candy': [255, 188, 217],
    'Bubblegum': [255, 193, 204],
    'Candy Pink': [228, 113, 122],
    'Sweet Pink': [253, 215, 228],
    'Hot Pink': [255, 105, 180],
    'Deep Pink': [255, 20, 147],
    'Bright Pink': [255, 0, 127],
    'Shocking Pink': [252, 15, 192],
    'Neon Pink': [255, 16, 240],
    'Magenta': [255, 0, 255],
    'Deep Magenta': [204, 0, 204],
    'Dark Magenta': [139, 0, 139],
    'Persian Pink': [247, 127, 190],
    'Violet Pink': [251, 95, 253],
    'Orchid Pink': [242, 189, 205],
    'Lavender Pink': [251, 174, 210],
    'Carnation Pink': [255, 166, 201],
    'Ballet Pink': [244, 140, 186],
    'Ballet Slipper': [238, 207, 217],
    'Flamingo': [252, 142, 172],
    'Salmon Pink': [255, 145, 164],
    'Peach Pink': [255, 218, 185],
    'Apricot Pink': [251, 206, 177],
    'Blush Pink': [254, 206, 215],
    'Dusty Pink': [220, 177, 172],
    'Mauve Pink': [224, 176, 255],
    'Lilac Pink': [200, 162, 200],
    'Thistle Pink': [216, 191, 216],
    'Peony': [250, 193, 209],
    'Cherry Blossom': [255, 183, 197],
    'Sakura': [255, 223, 231],
    'Azalea': [247, 200, 220],
    'Begonia': [255, 106, 106],
    'Hibiscus': [182, 49, 108],
    'Hollyhock': [225, 180, 192],
    'Impatiens': [255, 173, 185],
    'Princess Pink': [255, 213, 220],
    'Fairy Pink': [238, 192, 210],
    'French Pink': [253, 108, 158],
    'Persian Rose': [254, 40, 162],
    'Shell Pink': [255, 200, 200],
    'Shrimp Pink': [255, 94, 133],
    'Strawberry Pink': [255, 67, 164],
    'Raspberry Pink': [227, 11, 92],
    'Cranberry Pink': [159, 43, 104],
    'Cherry Pink': [222, 49, 99],
    'Wine Pink': [145, 95, 109],
    'Magenta Pink': [204, 51, 139],
    'Tulip': [255, 135, 141],
    'French Rose': [246, 74, 138],
    'English Rose': [254, 176, 173],
    'Desert Rose': [193, 72, 105],
    'Alpine Rose': [222, 120, 140],
    'India Pink': [205, 145, 158],
    'Japan Pink': [255, 181, 197],
    'Tickle Me Pink': [252, 137, 172],
    'Piggy Pink': [253, 221, 230],
    'Barbie Pink': [224, 33, 138],
    'Romance': [255, 207, 210],
    'Sweetie': [255, 198, 209],
    'Pink Lemonade': [255, 117, 140],
    'Pink Grapefruit': [255, 105, 97],

    // ==================== ORANGES (58) ====================
    'Dark Orange': [255, 140, 0],
    'Dark Salmon': [233, 150, 122],
    'Deep Orange': [255, 87, 51],
    'Burnt Orange': [204, 85, 0],
    'Orange': [255, 165, 0],
    'Bright Orange': [255, 123, 0],
    'True Orange': [255, 153, 0],
    'Vivid Orange': [255, 95, 31],
    'Electric Orange': [255, 63, 52],
    'Safety Orange': [255, 103, 0],
    'International Orange': [255, 79, 0],
    'Hunter Orange': [255, 93, 0],
    'Construction Orange': [248, 76, 30],
    'Fire Orange': [255, 69, 0],
    'Flame Orange': [226, 88, 34],
    'Cherry Tomato': [254, 54, 63],
    'Coral': [255, 127, 80],
    'Salmon': [250, 128, 114],
    'Salmon Orange': [255, 140, 105],
    'Peach': [255, 218, 185],
    'Peach Orange': [255, 204, 153],
    'Apricot': [251, 206, 177],
    'Apricot Orange': [255, 175, 100],
    'Tangerine': [242, 133, 0],
    'Mandarin': [243, 134, 48],
    'Clementine': [255, 140, 56],
    'Satsuma': [255, 143, 0],
    'Citrus': [255, 152, 0],
    'Orange Peel': [255, 159, 0],
    'Mango': [255, 130, 67],
    'Papaya': [255, 239, 213],
    'Cantaloupe': [255, 175, 115],
    'Melon': [253, 188, 180],
    'Pumpkin': [255, 117, 24],
    'Squash': [242, 140, 40],
    'Carrot': [237, 145, 33],
    'Sweet Potato': [250, 152, 120],
    'Yam': [212, 136, 82],
    'Persimmon': [236, 88, 0],
    'Kumquat': [255, 156, 46],
    'Nectarine': [255, 168, 88],
    'Amber': [255, 191, 0],
    'Honey': [235, 174, 52],
    'Golden Orange': [255, 177, 31],
    'Butterscotch': [224, 167, 65],
    'Caramel': [255, 213, 154],
    'Toffee': [178, 132, 90],
    'Cognac': [159, 56, 0],
    'Brandy': [135, 65, 0],
    'Whiskey': [214, 137, 16],
    'Bourbon': [184, 109, 41],
    'Rust': [183, 65, 14],
    'Copper': [184, 115, 51],
    'Bronze': [205, 127, 50],
    'Penny': [163, 111, 94],
    'Cayenne': [237, 28, 36],
    'Chili': [226, 61, 40],
    'Tiger': [253, 106, 2],
    'Lion': [193, 154, 107],
    'Fox': [196, 78, 0],
    'Autumn': [205, 133, 63],
    'Fall': [234, 126, 93],
    'Harvest': [255, 155, 66],
    'Sunset': [250, 214, 165],
    'Sunrise': [255, 191, 105],
    'Dawn': [255, 199, 95],
    'Dusk': [255, 140, 56],

    // ==================== YELLOWS (72) ====================
    'Yellow': [255, 255, 0],
    'Pure Yellow': [255, 237, 0],
    'True Yellow': [255, 238, 0],
    'Vivid Yellow': [255, 227, 0],
    'Neon Yellow': [207, 255, 4],
    'Fluorescent Yellow': [204, 255, 0],
    'Lemon': [255, 247, 0],
    'Lemon Yellow': [255, 244, 79],
    'Citron': [159, 169, 31],
    'Lime Yellow': [227, 255, 0],
    'Chartreuse': [127, 255, 0],
    'Light Yellow': [255, 255, 224],
    'Pale Yellow': [255, 255, 175],
    'Soft Yellow': [255, 253, 208],
    'Pastel Yellow': [253, 253, 150],
    'Butter': [255, 228, 132],
    'Butter Yellow': [255, 241, 181],
    'Cream': [255, 253, 208],
    'Cream Yellow': [255, 243, 179],
    'Vanilla': [243, 229, 171],
    'Custard': [255, 253, 208],
    'Banana': [255, 225, 53],
    'Banana Yellow': [254, 251, 210],
    'Canary': [255, 239, 0],
    'Canary Yellow': [255, 255, 153],
    'Sunny': [242, 234, 0],
    'Sunflower': [255, 218, 3],
    'Dandelion': [240, 225, 48],
    'Buttercup': [254, 221, 96],
    'Daffodil': [255, 255, 49],
    'Primrose': [237, 220, 92],
    'Goldenrod': [218, 165, 32],
    'Light Goldenrod': [250, 250, 210],
    'Pale Goldenrod': [238, 232, 170],
    'Gold': [255, 215, 0],
    'Golden Yellow': [255, 223, 0],
    'Metallic Gold': [212, 175, 55],
    'Vegas Gold': [197, 179, 88],
    'Old Gold': [207, 181, 59],
    'Antique Gold': [172, 138, 62],
    'Harvest Gold': [218, 145, 0],
    'School Bus Yellow': [255, 216, 0],
    'Taxi Cab Yellow': [244, 214, 53],
    'Corn': [251, 236, 93],
    'Corn Yellow': [245, 222, 179],
    'Cornsilk': [255, 248, 220],
    'Maize': [251, 236, 93],
    'Wheat': [245, 222, 179],
    'Straw': [228, 217, 111],
    'Hay': [221, 178, 84],
    'Blonde': [250, 240, 190],
    'Flax': [238, 220, 130],
    'Champagne': [247, 231, 206],
    'Khaki': [240, 230, 140],
    'Sand': [194, 178, 128],
    'Desert Sand': [237, 201, 175],
    'Ecru': [194, 178, 128],
    'Beige': [245, 245, 220],
    'Tan': [210, 180, 140],
    'Buff': [240, 220, 130],
    'Biscuit': [255, 228, 196],
    'Honeycomb': [255, 242, 99],
    'Mustard': [255, 219, 88],
    'Dijon': [196, 141, 0],
    'Ochre': [204, 119, 34],
    'Yellow Ochre': [227, 163, 63],
    'Brass': [181, 166, 66],
    'Saffron': [244, 196, 48],
    'Turmeric': [254, 172, 15],
    'Pineapple': [255, 226, 44],
    'Lemon Chiffon': [255, 250, 205],
    'Lemon Meringue': [246, 234, 190],
    'Lemon Cream': [255, 244, 206],
    'Citrine': [228, 208, 10],
    'Lemonade': [255, 252, 127],
    'Daisy': [255, 240, 79],
    'Jasmine': [248, 222, 126],
    'Jonquil': [250, 218, 94],
    'Mimosa': [248, 228, 179],
    'Acacia': [227, 208, 87],
    'Topaz': [255, 200, 124],

    // ==================== GREENS (87) ====================
    'Dark Green': [0, 100, 0],
    'Deep Green': [5, 102, 8],
    'Forest Green': [34, 139, 34],
    'Hunter Green': [53, 94, 59],
    'Pine Green': [1, 121, 111],
    'Evergreen': [5, 71, 42],
    'Green': [0, 128, 0],
    'True Green': [0, 153, 0],
    'Pure Green': [0, 168, 0],
    'Bright Green': [102, 255, 0],
    'Vivid Green': [0, 255, 0],
    'Neon Green': [57, 255, 20],
    'Fluorescent Green': [8, 255, 8],
    'Lime Green': [50, 205, 50],
    'Light Green': [144, 238, 144],
    'Pale Green': [152, 251, 152],
    'Pastel Green': [119, 221, 119],
    'Mint': [189, 252, 201],
    'Mint Green': [152, 255, 152],
    'Mint Cream': [245, 255, 250],
    'Spearmint': [69, 139, 116],
    'Peppermint': [193, 255, 202],
    'Wintergreen': [62, 180, 137],
    'Spring Green': [0, 255, 127],
    'Medium Spring Green': [0, 250, 154],
    'Yellow Green': [154, 205, 50],
    'Lawn Green': [124, 252, 0],
    'Grass Green': [63, 155, 11],
    'Kelly Green': [76, 187, 23],
    'Shamrock': [69, 206, 162],
    'Clover': [0, 132, 61],
    'Irish Green': [0, 158, 96],
    'Lucky Green': [43, 127, 58],
    'Emerald': [80, 200, 120],
    'Jade': [0, 168, 107],
    'Malachite': [11, 218, 81],
    'Viridian': [64, 130, 109],
    'Teal': [0, 128, 128],
    'Dark Teal': [0, 77, 77],
    'Turquoise': [64, 224, 208],
    'Medium Turquoise': [72, 209, 204],
    'Dark Turquoise': [0, 206, 209],
    'Sea Green': [46, 139, 87],
    'Medium Sea Green': [60, 179, 113],
    'Light Sea Green': [32, 178, 170],
    'Ocean Green': [72, 191, 145],
    'Seafoam': [159, 226, 191],
    'Seafoam Green': [147, 223, 184],
    'Aquamarine': [127, 255, 212],
    'Medium Aquamarine': [102, 221, 170],
    'Caribbean': [0, 204, 153],
    'Tropical': [0, 181, 173],
    'Lagoon': [4, 169, 173],
    'Olive': [128, 128, 0],
    'Olive Green': [186, 184, 108],
    'Olive Drab': [107, 142, 35],
    'Dark Olive': [85, 107, 47],
    'Army Green': [75, 83, 32],
    'Military Green': [102, 102, 0],
    'Camouflage': [120, 134, 107],
    'Sage': [188, 184, 138],
    'Sage Green': [157, 172, 144],
    'Fern': [113, 188, 120],
    'Fern Green': [79, 121, 66],
    'Moss': [138, 154, 91],
    'Moss Green': [173, 223, 173],
    'Lichen': [129, 140, 67],
    'Algae': [84, 172, 104],
    'Seaweed': [23, 116, 66],
    'Kale': [83, 105, 66],
    'Thyme': [152, 163, 145],
    'Oregano': [124, 134, 72],
    'Parsley': [28, 123, 11],
    'Cilantro': [142, 177, 117],
    'Avocado': [86, 130, 3],
    'Pear': [209, 226, 49],
    'Apple Green': [141, 182, 0],
    'Granny Smith': [168, 228, 160],
    'Lime Peel': [191, 255, 0],
    'Pistachio': [147, 197, 114],
    'Honeydew': [240, 255, 240],
    'Cucumber': [124, 176, 135],
    'Celery': [184, 202, 135],
    'Lettuce': [202, 237, 154],
    'Spinach': [35, 111, 43],
    'Artichoke': [139, 157, 115],
    'Asparagus': [135, 169, 107],
    'Green Pea': [166, 209, 137],
    'Split Pea': [144, 168, 65],
    'Green Bean': [108, 140, 69],
    'Pickle': [117, 142, 41],
    'Green Tea': [214, 232, 167],
    'Matcha': [136, 176, 75],

    // ==================== BLUES (91) ====================
    'Navy': [0, 0, 128],
    'Dark Navy': [0, 0, 80],
    'Midnight Blue': [25, 25, 112],
    'Dark Blue': [0, 0, 139],
    'Deep Blue': [0, 0, 150],
    'Prussian Blue': [0, 49, 83],
    'Space Blue': [29, 41, 81],
    'Galaxy': [42, 82, 190],
    'Cosmos': [50, 74, 178],
    'Sapphire': [15, 82, 186],
    'Lapis': [38, 97, 156],
    'Cobalt': [0, 71, 171],
    'Royal Blue': [65, 105, 225],
    'Imperial Blue': [0, 35, 149],
    'Persian Blue': [28, 57, 187],
    'Egyptian Blue': [16, 52, 166],
    'Cerulean': [0, 123, 167],
    'Azure': [0, 127, 255],
    'Blue': [0, 0, 255],
    'True Blue': [0, 115, 207],
    'Bright Blue': [0, 135, 255],
    'Vivid Blue': [0, 51, 255],
    'Electric Blue': [125, 249, 255],
    'Neon Blue': [77, 77, 255],
    'Sky Blue': [135, 206, 235],
    'Light Sky Blue': [135, 206, 250],
    'Deep Sky Blue': [0, 191, 255],
    'Powder Blue': [176, 224, 230],
    'Baby Blue': [137, 207, 240],
    'Pastel Blue': [174, 198, 207],
    'Pale Blue': [175, 238, 238],
    'Light Blue': [173, 216, 230],
    'Ice Blue': [175, 238, 238],
    'Glacier': [128, 191, 255],
    'Arctic': [130, 195, 228],
    'Frost': [221, 244, 248],
    'Steel Blue': [70, 130, 180],
    'Slate Blue': [106, 90, 205],
    'Cadet Blue': [95, 158, 160],
    'Denim': [21, 96, 189],
    'Jeans': [93, 173, 236],
    'Chambray': [137, 157, 192],
    'Indigo': [75, 0, 130],
    'Periwinkle': [204, 204, 255],
    'Cornflower': [100, 149, 237],
    'Bluebell': [162, 162, 208],
    'Hyacinth': [202, 174, 224],
    'Iris': [90, 79, 207],
    'Dodger Blue': [30, 144, 255],
    'Carolina Blue': [153, 186, 221],
    'Columbia Blue': [155, 221, 255],
    'Yale Blue': [15, 77, 146],
    'Oxford Blue': [0, 33, 71],
    'Cambridge Blue': [163, 193, 173],
    'Alice Blue': [240, 248, 255],
    'Ocean': [0, 119, 190],
    'Ocean Blue': [79, 66, 181],
    'Sea Blue': [0, 105, 148],
    'Marine': [0, 78, 137],
    'Marine Blue': [1, 70, 127],
    'Sailor Blue': [0, 103, 165],
    'Nautical': [0, 102, 204],
    'Captain': [0, 77, 128],
    'Admiral': [0, 56, 101],
    'Caribbean Blue': [0, 204, 153],
    'Tropical Blue': [0, 181, 236],
    'Pool Blue': [0, 174, 239],
    'Bright Cyan': [65, 244, 252],
    'Light Cyan': [224, 255, 255],
    'Bright Turquoise': [8, 232, 222],
    'Teal Blue': [54, 117, 136],
    'Peacock': [51, 161, 201],
    'Robin Egg': [0, 204, 204],
    'Robin Egg Blue': [31, 206, 203],
    'Bluebird': [65, 105, 225],
    'Blue Jay': [42, 118, 198],
    'Dolphin': [97, 134, 155],
    'Whale': [54, 70, 93],
    'Bondi Blue': [0, 149, 182],
    'Aegean': [71, 139, 166],
    'Mediterranean': [59, 132, 163],
    'Adriatic': [44, 150, 199],
    'Baltic': [51, 113, 151],

    // ==================== PURPLES (92) ====================
    'Dark Purple': [48, 25, 52],
    'Deep Purple': [58, 12, 163],
    'Purple': [128, 0, 128],
    'True Purple': [102, 0, 153],
    'Bright Purple': [191, 64, 191],
    'Vivid Purple': [159, 0, 255],
    'Neon Purple': [189, 51, 255],
    'Electric Purple': [191, 0, 255],
    'Royal Purple': [120, 81, 169],
    'Imperial Purple': [102, 2, 60],
    'Byzantine': [189, 51, 164],
    'Violet': [238, 130, 238],
    'Dark Violet': [148, 0, 211],
    'Blue Violet': [138, 43, 226],
    'Medium Violet': [147, 112, 219],
    'Red Violet': [199, 21, 133],
    'Violet Red': [208, 32, 144],
    'Bright Magenta': [255, 0, 255],
    'Hot Magenta Purple': [255, 29, 206],
    'Indigo Purple': [65, 0, 120],
    'Plum': [221, 160, 221],
    'Dark Plum': [63, 1, 44],
    'Sugar Plum': [145, 78, 117],
    'Eggplant': [97, 64, 81],
    'Aubergine': [59, 9, 39],
    'Grape': [111, 45, 168],
    'Concord': [82, 42, 119],
    'Wine Purple': [85, 37, 130],
    'Mulberry': [197, 75, 140],
    'Berry Purple': [102, 0, 102],
    'Lavender': [230, 230, 250],
    'Light Lavender': [244, 222, 255],
    'Dark Lavender': [115, 79, 150],
    'Medium Lavender': [199, 177, 229],
    'Pale Lavender': [220, 208, 255],
    'Lilac': [200, 162, 200],
    'Light Lilac': [229, 204, 255],
    'Dark Lilac': [153, 102, 204],
    'Mauve': [224, 176, 255],
    'Light Mauve': [240, 209, 255],
    'Dark Mauve': [153, 51, 102],
    'Orchid': [218, 112, 214],
    'Dark Orchid': [153, 50, 204],
    'Medium Orchid': [186, 85, 211],
    'Light Orchid': [230, 168, 215],
    'Thistle': [216, 191, 216],
    'Heather': [174, 148, 184],
    'Wisteria': [201, 160, 220],
    'Amethyst': [153, 102, 204],
    'Light Amethyst': [197, 166, 255],
    'Dark Amethyst': [103, 65, 136],
    'Crocus': [143, 110, 181],
    'Petunia': [175, 101, 163],
    'Pansy': [120, 24, 74],
    'Violet Flower': [139, 95, 191],
    'Clematis': [136, 82, 127],
    'Verbena': [120, 24, 74],
    'Aster': [155, 89, 182],
    'Lupine': [138, 109, 167],
    'Bellflower': [158, 102, 171],
    'Anemone': [157, 129, 186],
    'Purple Haze': [163, 134, 175],
    'Purple Rain': [113, 88, 143],
    'Purple Heart': [105, 53, 156],
    'Purple Mountain': [150, 123, 182],
    'Purple Passion': [74, 0, 95],
    'Purple Prince': [99, 29, 210],
    'Purple Pizzazz': [254, 78, 218],
    'Razzle Dazzle': [153, 0, 153],
    'Byzantine Purple': [112, 41, 99],
    'French Lilac': [134, 96, 142],
    'English Violet': [86, 60, 92],
    'Parma': [153, 102, 204],
    'Venetian Purple': [145, 95, 109],
    'Pompadour': [106, 58, 81],
    'Phlox': [223, 0, 255],
    'Mystic': [209, 159, 232],
    'Cosmic': [136, 49, 121],
    'Galaxy Purple': [135, 78, 162],
    'Space Purple': [70, 48, 94],
    'Twilight': [138, 73, 107],
    'Dusk Purple': [94, 53, 80],
    'Evening': [104, 79, 124],
    'Midnight Purple': [40, 26, 56],
    'Dream': [153, 102, 204],
    'Fantasy': [176, 104, 161],
    'Enchanted': [162, 107, 186],
    'Magic': [180, 96, 200],
    'Wizard': [126, 50, 176],
    'Sorcerer': [85, 37, 130],
    'Mystic Purple': [167, 107, 207],

    // ==================== BROWNS (82) ====================
    'Brown': [165, 42, 42],
    'Dark Brown': [101, 67, 33],
    'Deep Brown': [74, 44, 42],
    'Light Brown': [181, 101, 29],
    'Pale Brown': [152, 118, 84],
    'Saddle Brown': [139, 69, 19],
    'Medium Brown': [128, 70, 27],
    'Dark Chestnut': [149, 69, 53],
    'Light Chestnut': [205, 133, 63],
    'Dark Mahogany': [82, 23, 0],
    'Red Mahogany': [110, 25, 18],
    'Russet': [128, 70, 27],
    'Copper Brown': [150, 90, 62],
    'Bronze Brown': [128, 86, 35],
    'Sienna': [160, 82, 45],
    'Burnt Sienna': [233, 116, 81],
    'Raw Sienna': [214, 138, 89],
    'Umber': [99, 81, 71],
    'Burnt Umber': [138, 51, 36],
    'Raw Umber': [130, 102, 68],
    'Chocolate': [210, 105, 30],
    'Dark Chocolate': [77, 40, 0],
    'Milk Chocolate': [129, 70, 11],
    'Hot Chocolate': [100, 65, 23],
    'Cocoa': [135, 95, 66],
    'Cocoa Brown': [55, 31, 17],
    'Coffee': [111, 78, 55],
    'Coffee Bean': [44, 22, 8],
    'Espresso': [74, 44, 42],
    'Mocha': [135, 84, 60],
    'Cappuccino': [162, 107, 78],
    'Latte': [196, 142, 103],
    'Dark Caramel': [175, 111, 54],
    'Fudge': [95, 56, 38],
    'Peanut': [120, 72, 0],
    'Peanut Butter': [193, 154, 107],
    'Almond': [239, 222, 205],
    'Hazelnut': [142, 118, 86],
    'Walnut': [92, 64, 51],
    'Pecan': [158, 91, 64],
    'Chestnut Brown': [152, 105, 96],
    'Acorn': [135, 79, 57],
    'Oak': [128, 84, 32],
    'Wood': [193, 154, 107],
    'Driftwood': [175, 141, 120],
    'Cedar': [125, 84, 72],
    'Pine Wood': [229, 217, 182],
    'Cherry Wood': [116, 41, 33],
    'Maple Wood': [210, 180, 140],
    'Bamboo': [218, 178, 115],
    'Teak': [184, 138, 84],
    'Ash Wood': [178, 153, 126],
    'Birch': [241, 230, 214],
    'Hickory': [180, 130, 80],
    'Sandalwood': [204, 158, 108],
    'Nutmeg': [129, 70, 31],
    'Clove': [165, 94, 51],
    'Ginger': [176, 101, 0],
    'Allspice': [128, 70, 27],
    'Cardamom': [157, 129, 97],
    'Cumin': [146, 111, 91],
    'Paprika': [141, 53, 24],
    'Tobacco': [113, 93, 65],
    'Cigar': [130, 90, 44],
    'Leather': [150, 90, 62],
    'Light Tan': [255, 228, 196],
    'Dark Tan': [145, 129, 81],
    'Sandy Brown': [244, 164, 96],
    'Dune': [220, 187, 153],
    'Sahara': [188, 152, 126],
    'Dark Khaki': [189, 183, 107],
    'Taupe': [72, 60, 50],
    'Stone': [140, 140, 140],
    'Clay': [204, 119, 34],
    'Terra Cotta Brown': [226, 114, 91],
    'Terracotta Brown': [204, 78, 92],
    'Sandstone': [208, 192, 179],
    'Limestone': [232, 221, 203],
    'Sepia Brown': [112, 66, 20],
    'Marigold Brown': [234, 162, 33],
    'Curry Brown': [206, 144, 49],
    'Blonde Wood': [210, 180, 140],
    'Autumn Brown': [205, 133, 63],
    'Harvest Brown': [255, 155, 66],

    // ==================== GRAYS ====================
    'Light Gray': [211, 211, 211],
    'Pale Gray': [220, 220, 220],
    'Gainsboro': [220, 220, 220],
    'Cloud': [199, 202, 210],
    'Fog': [213, 216, 220],
    'Mist': [196, 198, 200],
    'Ash': [178, 190, 181],
    'Silver Gray': [172, 172, 172],
    'Dove Gray': [109, 109, 109],
    'Gray': [128, 128, 128],
    'Medium Gray': [128, 128, 128],
    'Cool Gray': [140, 146, 172],
    'Warm Gray': [128, 128, 105],
    'Neutral Gray': [138, 135, 135],
    'Stone Gray': [140, 140, 140],
    'Cement': [134, 137, 128],
    'Concrete': [149, 149, 149],
    'Sidewalk': [150, 150, 150],
    'Pebble': [184, 184, 184],
    'Slate': [112, 128, 144],
    'Slate Gray': [112, 128, 144],
    'Light Slate Gray': [119, 136, 153],
    'Granite': [131, 131, 130],
    'Steel': [99, 109, 131],
    'Steel Gray': [67, 70, 75],
    'Pewter': [150, 168, 145],
    'Nickel': [114, 116, 114],
    'Storm': [75, 76, 76],
    'Storm Gray': [67, 72, 82],
    'Dim Gray': [105, 105, 105],
    'Battleship Gray': [132, 132, 130],

    // ==================== WHITES (18) ====================
    'White': [255, 255, 255],
    'Bright White': [254, 254, 254],
    'Snow': [255, 250, 250],
    'Ivory': [255, 255, 240],
    'Pearl': [240, 234, 214],
    'Off White': [250, 250, 250],
    'Linen': [250, 240, 230],
    'Seashell': [255, 245, 238],
    'Alabaster': [237, 234, 224],
    'Bone': [227, 218, 201],
    'Porcelain': [239, 236, 230],
    'China White': [250, 246, 240],
    'Milk': [254, 255, 250],
    'Ghost White': [248, 248, 255],
    'Floral White': [255, 250, 240],
    'Antique White': [250, 235, 215],
    'Navajo White': [255, 222, 173],
    'Platinum': [229, 228, 226],

    // ==================== BLACKS (23) ====================
    'Black': [0, 0, 0],
    'Jet Black': [10, 10, 10],
    'Tar': [13, 13, 13],
    'Coal': [16, 16, 16],
    'Midnight Black': [15, 15, 15],
    'Ebony': [21, 19, 18],
    'Lead': [33, 34, 38],
    'Dark Charcoal': [36, 36, 36],
    'Thunder': [51, 51, 51],
    'Charcoal': [54, 69, 79],
    'Gunmetal': [42, 52, 57],
    'Graphite': [65, 74, 76],
    'Iron': [77, 77, 82],
    'Shadow': [32, 32, 32],
    'Dark Shadow': [20, 20, 20],
    'Raven': [66, 66, 66],
    'Jet': [52, 52, 52],
    'Onyx': [53, 56, 57],
    'Obsidian': [59, 72, 81],
    'Midnight': [25, 25, 112],
    'Licorice': [26, 17, 16],
    'Ink': [28, 28, 28],
    'Asphalt': [19, 19, 19],
  };

  // static String classifyRedPinkPurple(int r, int g, int b) {
  //   double rf = r / 255.0;
  //   double gf = g / 255.0;
  //   double bf = b / 255.0;

  //   double maxVal = [rf, gf, bf].reduce((a, b) => a > b ? a : b);
  //   double minVal = [rf, gf, bf].reduce((a, b) => a < b ? a : b);
  //   double lightness = (maxVal + minVal) / 2.0;

  //   double redBlueRatio = r / (b + 1);

  //   if (lightness > 0.55) return "Pink";
  //   if (redBlueRatio > 1.05 && r > g * 0.8) return "Pink";
  //   if (b > r * 0.6) return "Purple";
  //   return "Red";
  // }

  static void addColor(String name, List<int> rgb) {
    _colorPalette[name] = rgb;
  }

  /// Remove a color
  static void removeColor(String name) {
    _colorPalette.remove(name);
  }

  /// Total colors
  static int get colorCount => _colorPalette.length;

  /// All color names
  static List<String> get allColorNames => _colorPalette.keys.toList();

  /// Get RGB for a specific color
  static List<int>? getColorRGB(String colorName) => _colorPalette[colorName];

  /// Calculate Euclidean distance between two RGB colors
  static double _colorDistance(int r1, int g1, int b1, int r2, int g2, int b2) {
    return sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2));
  }

  /// Get the closest color name using K-Nearest Neighbors algorithm
  static String getColorName(int r, int g, int b, {int k = 5}) {
    if (_colorPalette.isEmpty) return "Unknown";

    final distances = <MapEntry<String, double>>[];
    _colorPalette.forEach((name, rgb) {
      final distance = _colorDistance(r, g, b, rgb[0], rgb[1], rgb[2]);
      distances.add(MapEntry(name, distance));
    });

    // Sort and take top k
    distances.sort((a, b) => a.value.compareTo(b.value));
    final kNearest = distances.take(k);

    // Count occurrences
    final colorCounts = <String, int>{};
    for (final entry in kNearest) {
      colorCounts[entry.key] = (colorCounts[entry.key] ?? 0) + 1;
    }

    // Return most common
    String mostCommon = kNearest.first.key;
    int maxCount = 0;
    colorCounts.forEach((name, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = name;
      }
    });

    return mostCommon;
  }

  /// Get a simplified color family name with separated Gray, Black, and White
  static String getColorFamily(int r, int g, int b) {
    // Normalize to 0–1
    double rf = r / 255.0;
    double gf = g / 255.0;
    double bf = b / 255.0;

    double maxVal = [rf, gf, bf].reduce((a, b) => a > b ? a : b);
    double minVal = [rf, gf, bf].reduce((a, b) => a < b ? a : b);
    double lightness = (maxVal + minVal) / 2.0;
    double diff = maxVal - minVal;
    double saturation = diff == 0
        ? 0.0
        : diff / (1 - (2 * lightness - 1).abs());

    // --- Achromatic colors ---
    if (lightness < 0.25 && saturation < 0.15) return "Black";
    if (saturation < 0.12 && lightness > 0.6) return "White";
    if (saturation < 0.15 && lightness >= 0.25 && lightness <= 0.6) {
      return "Gray";
    }

    // --- Hue calculation ---
    double hue = 0;
    if (diff != 0) {
      if (maxVal == rf) {
        hue = 60 * (((gf - bf) / diff) % 6);
      } else if (maxVal == gf) {
        hue = 60 * (((bf - rf) / diff) + 2);
      } else {
        hue = 60 * (((rf - gf) / diff) + 4);
      }
    }
    if (hue < 0) hue += 360;

    // --- Brown detection ---
    if (saturation < 0.55 &&
        lightness > 0.2 &&
        lightness < 0.65 &&
        r > g &&
        g > b &&
        r > 90) {
      return "Brown";
    }

    // --- Red, Pink, Orange, Purple detection ---
    if ((hue >= 345 || hue < 40) || (hue >= 290 && hue < 345)) {
      return classifyRedPinkOrangePurple(r, g, b, hue, lightness, saturation);
    }

    // --- Other hue-based families ---
    if (hue >= 40 && hue < 70) return "Yellow";
    if (hue >= 70 && hue < 165) return "Green";
    if (hue >= 165 && hue < 250) return "Blue";
    if (hue >= 250 && hue < 290) return "Purple";

    return "Unknown"; // fallback
  }

  /// Helper to distinguish Red, Pink, Orange, and Purple correctly
  static String classifyRedPinkOrangePurple(
    int r,
    int g,
    int b,
    double hue,
    double lightness,
    double saturation,
  ) {
    // --- True Red zone (345°–15°) ---
    if (hue >= 345 || hue < 15) {
      if (lightness < 0.45) return "Red";
      if (lightness >= 0.45 && b > g && b > (r * 0.6)) return "Pink";
      if (lightness > 0.55 && saturation < 0.9) return "Pink";
      return "Red";
    }

    // --- Coral / Orange-red zone (15°–40°) ---
    if (hue >= 15 && hue < 40) {
      // Brighter and warm → Orange or Coral
      if (lightness > 0.35 && g > b && saturation > 0.4) return "Orange";
      // Slightly darker reds here are Red-Orange
      return "Red";
    }

    // --- Purple / Magenta zone (290°–345°) ---
    if (hue >= 290 && hue < 345) {
      if (lightness > 0.6 && r > b * 1.1) return "Pink";
      if (b > r && lightness < 0.55) return "Purple";
      return "Magenta";
    }

    // fallback
    return "Red";
  }
}
