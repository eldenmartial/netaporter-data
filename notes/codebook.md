# Codebook

This is the rulebook for labeling products. Every product gets labels for the same fields, and every label comes from a fixed list. That way my labels and the AI's labels can be compared fairly.

The lists come from counting words in all product names (`sql/explore/01_vocabulary.sql`, `02_phrases.sql`, `03_material_counts.sql`).

## How to label

1. Look only at the **brand, product name, and type**. Never look at the price. The AI won't see the price either, so I shouldn't.
2. Pick **one value per field** from the lists below. If nothing fits, use `other` (or `none` / `not stated` where the list has it).
3. If a product is hard to decide, pick your best answer and write why in the `notes` column.
4. If you change a rule while labeling, write it in `decisions.md` and go back and fix any products the change affects.

## Fields I label by hand

### 1. subtype: what the item is

**Simple version:** The kind of thing it is. A dress, a coat, a pair of boots. It's usually the last word in the name.

**Rules**
- Use the last main noun. "Silk Midi **Dress**" → `dress`.
- Length words (mini, midi, maxi) are not part of the subtype. "Mini dress," "midi dress," and "maxi dress" are all `dress`. Length is its own field, filled in automatically.
- Words that describe *where you wear it* don't change the subtype. "Ski Jacket" → `jacket`. "Track Pants" → `pants`.
- "Tie" in a name almost always means a tie detail ("Tie-Front Top"), not a necktie. Label the main item.

**Clothing**

| Value | Also includes |
|---|---|
| dress | mini, midi, maxi, shirt dress, slip dress |
| gown | |
| skirt | mini, midi, maxi skirt |
| pants | track pants, flared pants, wide-leg, cargo |
| jeans | |
| leggings | |
| shorts | |
| top | tank, camisole, bustier |
| shirt | blouse, poplin shirt, polo |
| t-shirt | |
| sweater | turtleneck |
| cardigan | |
| sweatshirt | hoodie |
| jacket | bomber, biker, ski jacket |
| blazer | |
| coat | cape |
| trench coat | |
| vest | |
| jumpsuit | playsuit |
| bodysuit | |
| set | two-piece set |
| bikini | bikini top, bikini briefs |
| swimsuit | one-piece |
| bra | bralette, sports bra |
| underwear | briefs, thong |
| sleepwear | pajamas, robe |
| cover-up | kaftan, pareo |

**Shoes**

| Value | Also includes |
|---|---|
| boots | ankle boots, knee boots, Chelsea boots |
| pumps | slingback pumps |
| sandals | slides, wedges, platforms |
| sneakers | |
| mules | |
| flats | ballet flats, Mary Janes |
| loafers | |

Anything else → `other` (for example espadrilles or slippers, which are too rare to get their own group).

### 2. material: what it's made of

**Simple version:** The *stuff* the item is made from, like the fiber or the skin. Cotton comes from a plant. Wool comes from a sheep. Leather comes from an animal hide.

**Rules**
- **Trims don't count.** A trim is a small edge or detail. "Leather-Trimmed Cotton Dress" → `cotton`, because the dress is mostly cotton.
- **Blends count as the main material.** "Wool-Blend Coat" → `wool`.
- **If two materials are named, use the first one.** "Wool and Cashmere-Blend Sweater" → `wool`. "Silk-Satin Dress" → `silk`.
- **"Faux" wins over what comes after it.** "Faux Leather Pants" → `faux leather or fur`, not `leather`.
- If no material is named, use `not stated`. Don't guess. "Satin Midi Dress" doesn't say what the satin is made of, so material is `not stated` (but fabric is `satin`).

| Value | Also includes |
|---|---|
| cotton | pima cotton, organic cotton |
| wool | merino |
| cashmere | |
| silk | |
| linen | ramie |
| leather | patent leather, calf hair |
| suede | |
| shearling | |
| faux leather or fur | anything starting with "faux" |
| down | down-filled (but not "button-down") |
| mohair or alpaca | |
| wood-based | modal, Tencel, lyocell, viscose, Ecovero |
| plastic | PVC, rubber |
| other | real fur, feathers as the main material, anything else |
| not stated | no material named |

**Known limit:** about 41% of products don't name a material. Most of those name a fabric instead ("Satin," "Crepe," "Jersey"), which is why fabric is its own field.

### 3. fabric: how the material is made into cloth

**Simple version:** Material is the *ingredient*. Fabric is the *recipe*. The same cotton can be woven into crisp poplin or knitted into soft jersey, and they look and feel totally different.

**Rules**
- "Stretch" and "blend" are not fabrics. Skip them. "Stretch-Jersey Top" → `jersey`.
- If two fabrics are named, use the first one.
- Shoes and many accessories won't have one → `none`.

| Value | Also includes |
|---|---|
| jersey | T-shirt fabric |
| knit | ribbed, cable-knit, pointelle, intarsia, Fair Isle |
| crochet | crocheted |
| satin | charmeuse, duchesse satin |
| crepe | crepe de chine, georgette, cady, crepon |
| poplin | |
| twill | gabardine |
| denim | |
| lace | guipure |
| broderie anglaise | |
| tulle | |
| chiffon or organza | sheer, floaty fabrics |
| voile | |
| jacquard | brocade, cloqué |
| velvet | |
| mesh | |
| tweed or bouclé | |
| corduroy | |
| taffeta | faille |
| canvas | |
| fleece or terry | |
| other | anything else named |
| none | no fabric named |

### 4. pattern: what's printed or woven on it

**Simple version:** The design on the fabric, like flowers or stripes. If it's one plain color, the pattern is `none`.

| Value | Also includes |
|---|---|
| floral | |
| striped | pinstriped |
| checked | gingham, houndstooth, plaid |
| polka dot | |
| animal print | leopard, zebra |
| paisley | |
| other print | "printed" or "print" with no other clue |
| none | plain |

### 5. finish: special details added on top

**Simple version:** The extra fancy things that make an item stand out: sparkles, pleats, fringe, a shiny coating. Pick the **one** detail you'd notice first.

**Rules**
- Pick only one. If there are several, choose the most eye-catching.
- Cut and shape words (cropped, oversized, asymmetric, cutout) are **not** finishes.
- **Change from my word list:** pleated, ruched, gathered, ruffled, and quilted were labeled as fabric types in the vocabulary file. They're really details added to the fabric, so they're finishes here.

| Value | Also includes |
|---|---|
| embellished | crystal, beaded, pearl, sequined, studded, glittered |
| embroidered | appliqué |
| trimmed | leather-, lace-, satin-, feather-trimmed |
| pleated | plissé, pintucked |
| ruched or gathered | shirred, smocked, draped |
| ruffled | tiered |
| quilted or padded | |
| fringed | |
| distressed | frayed |
| metallic | lamé |
| glossy | patent, glossed, coated |
| animal effect | croc-effect, snake-effect |
| logo | logo-print, logo-detailed, signature hardware like horsebit |
| belted or buckled | |
| bow or knot | |
| two-tone | color-block |
| none | no special detail |

### 6. collab_partner: the other brand, if it's a collaboration

**Simple version:** Sometimes two brands make something together. This is the second brand's name.

**Rules**
- If the name starts with "+" (like "+ Off-White Air Force 1"), write the partner's name exactly as shown.
- Product lines from the same brand are **not** collaborations. SKIMS "Fits Everybody," Valentino "Rockstud," and Loewe "Paula's Ibiza" are just names of collections.
- Otherwise leave it blank.

### 7. staple_or_statement: classic or trendy?

**Simple version:**
- A **staple** is a classic you could wear for years and it would still look right. Think of a plain wool coat or a white shirt.
- A **statement** piece is made to stand out *right now*. It's bold, sparkly, or unusual, and it might look dated in a few years.

**Signs of a staple:** a classic shape (trench coat, turtleneck, straight-leg jeans), plain colors, natural materials, no special finish.

**Signs of a statement:** sparkles or embellishment, feathers, cutouts, unusual cuts, bright prints, trend names (like "Y2K").

**Examples**

| Product | Label | Why |
|---|---|---|
| Cashmere Turtleneck Sweater | staple | Classic shape, classic material |
| Wool Trench Coat | staple | A wardrobe basic for decades |
| Leather Ankle Boots | staple | Goes with almost everything |
| Crystal-Embellished Cutout Mini Dress | statement | Sparkles plus a bold cut |
| Feather-Trimmed Satin Top | statement | Feathers are a trend detail |
| Metallic Platform Sandals | statement | Shiny and dramatic |

**Tie-breaker:** If you could wear it for more than three seasons without it looking dated, it's a `staple`. Always choose one, and use the `notes` column for borderline cases.

## Fields the computer fills in (no hand labels needed)

These follow simple, exact rules, so SQL can fill them in perfectly. Saving the AI for the fields that need judgment keeps it cheaper and keeps the validation focused.

| Field | Rule |
|---|---|
| length | `mini`, `midi`, or `maxi` if the word is in the name; otherwise `none` |
| is_collab | true if the name starts with "+" (already in the `products` table) |
| is_sustainable | true if the name includes "NET SUSTAIN" (Net-a-Porter's sustainability label) |

## Words to ignore

Some common words aren't useful for any field: "and," "the," "with," "one," "two," "double," "high," "rise," "leg." They're usually pieces of longer phrases like "off-the-shoulder" or "high-rise straight-leg."

# Codebook Brands

## Categories

    HL
    High Luxury / Heritage Luxury

    QL
    Quiet Luxury

    CD
    Contemporary Designer

    FO
    Feminine / Occasionwear

    FA
    Footwear / Accessories

    SW
    Swimwear


    DN
    Denim

    SP
    DesignerSportswear / Performance

    LE
    Lifestyle Essentials / Everyday Basics
