class JengaTower {  

    ArrayList<JengaBlock> blocks = new ArrayList<JengaBlock>();
    JengaBlock selectedBlock = null;
    PVector towerSize = new PVector(3,18);
    PVector cursorPos = new PVector(1,10);
    Boolean isCollapsed = false;
    Boolean blockIsSelected = false;
    color[] colours = {#007fff, #0066cc, #004c99, #003366, #001933};
    JSONObject pivotMapObject = loadJSONObject("WeightDistributionMap.json");
    JSONArray sectionMapArray = loadJSONArray("SectionMap.json");
    
    JengaTower() {
        // Populates the blocks array list. Specifies the starting position of each block, and randomly assigns it a colour from the colours array.
        for (int block = 0; block < (towerSize.y * towerSize.x); block++) {
            blocks.add(
                new JengaBlock(
                    (block % 3),
                    int(block / 3),
                    colours[int(random(colours.length-1))]
                )
            );
        }
    }
    
    void displayTower() {
        if (blockIsSelected) {selectedBlock.pos.set(cursorPos);}
        // Displays each block, using a different colour if the block is in the same location as the cursor.
        blocks.forEach((block) -> {fill(block.pos.y == cursorPos.y && block.pos.x == cursorPos.x ? #cce5ff: block.blockColor); block.display();});
    }
    
    void towerInterface() {
        // Handles all user input that directly relates to the tower. Used to move the cursor, and pickup and place blocks.
        // Controls in place to prevent the cursor from moving outside the bounds of the tower.
        if (gameInProgres && !isCollapsed) {
            switch(key) {
                case 'w': cursorPos.y += ((cursorPos.y - int(blockIsSelected)) < (towerSize.y - 1) ? 1 : 0); break;
                case 's': cursorPos.y -= (cursorPos.y > 0 ? 1 : 0); break;
                case 'd': cursorPos.x += (cursorPos.x < (towerSize.x - 1) ? 1 : 0); break;
                case 'a': cursorPos.x -= (cursorPos.x > 0 ? 1 : 0); break;
                case 'f': pickUpAndPlace(); break;
            }
        }
    }

    void pickUpAndPlace() {
        // Checks whether there is a block in the highlighted space and whether a block is already selected.
        // If a block hasn't been selected and the space isn't empty, the highlighted block is selected,
        // If a block has been selected and the space doesn't already contain a block, the selected block is placed in the empty space.
        // If the selected block is placed on the top of the tower, increases the height of the tower (stored in towerSize.y).
        // Does nothing if a block has been selected but the space already contains a block.
        ArrayList<JengaBlock> overlappingBlocks = new ArrayList<JengaBlock>();
        blocks.forEach((block) -> {if (cursorPos.y == block.pos.y && cursorPos.x == block.pos.x) {overlappingBlocks.add(block);}});
        if (overlappingBlocks.size() + int(blockIsSelected) == 1) {
                selectedBlock = overlappingBlocks.get(0);
                blockIsSelected = true;
                letsGetPhyiscal();
        } else if (overlappingBlocks.size() + int(blockIsSelected) == 2) {
            if (selectedBlock.pos.y == towerSize.y) {
                towerSize.y++;
            };
            selectedBlock = null;
            blockIsSelected = false;
            letsGetPhyiscal();
        }
    }
    
    void letsGetPhyiscal() {
        println("New Run!");
        // Calculates whether or not the tower should collapse, each time a block is removed or placed.
        // Creates and populates an array called structure representing the layout of the tower,
        // using 1's and 0s to represent empty and occupied sections, respectively.
        int[][] structure = new int [int(towerSize.y)][9];
        for (JengaBlock block: blocks) {
            for(int section = 0; section < 9; section++) {
                structure[int(block.pos.y)][section] += sectionMapArray.getJSONArray(int(block.pos.x)).getJSONArray(section).getInt(int(block.pos.y % 2));
            }
        }
        // Loops through each pivot point (row of blocks), starting at the top of the tower and working down.
        // Converts the 0's and 1's representing the structure of each pivot point to a binary string.
        // Then converts this binary string to an integer in order to generate a different number for each unique
        // layout. Depending on the result, either does nothing, or goes on to calculate the weight distribution above the
        // pivot point in question. If the lean in any direction is too great, the tower collapses, else does nothing.
        for (int pivot = structure.length - 1; pivot >= 0; pivot--) {
            int pivotStructure = unbinary(str(structure[pivot][0]) + str(structure[pivot][(pivot % 2 == 1 ? 1 : 3)]) + str(structure[pivot][(pivot % 2 == 1 ? 2 : 6)]));
            println("===========================================================");
            println("Pivot No: " + pivot);
            println(str(structure[pivot][0]) + str(structure[pivot][(pivot % 2 == 1 ? 1 : 3)]) + str(structure[pivot][(pivot % 2 == 1 ? 2 : 6)]));
            println("Pivot Structure:" + pivotStructure);
            if (pivotStructure == 1 || pivotStructure == 2 || pivotStructure == 3 || pivotStructure == 4 || pivotStructure == 6) {
                int[] weightDistribution = new int [9];
                for (int row = pivot + 1; row < int(towerSize.y); row++) {
                    for (int section = 0; section < 9; section++) {
                        weightDistribution[section] += structure[row][section] * pivotMapObject.getJSONObject("RowConfig" + pivotStructure).getJSONArray("section" + section + "Weight").getInt(pivot % 2);
                    }
                }
                int lean = 0;
                for (int weight: weightDistribution) {
                    lean += weight;
                }
                println("Lean: " + lean);
                if (lean > (pivotStructure == 3 || pivotStructure == 6 ? -1000 : -3) && lean < 3) {
                    continue;
                } else {
                    final int pointOfFailure = pivot;
                    isCollapsed = true;
                    blocks.forEach(
                        (block) -> {
                            if(block.pos.y > pointOfFailure) {
                                block.collapse();
                            }
                        }
                    );
                }
            }
        }
    }
}
