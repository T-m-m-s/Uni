 // ==========================================================
    // DIY STREAM DECK LITE - COMPLETE 2-PIECE ENCLOSURE (FIXED)
    // ==========================================================
    $fn = 40; // Circle smoothness
    
    // --- CHOOSE WHAT TO RENDER ---
    // Options: "both", "top", "bottom", "assembled"
    part_to_render = "both"; 
    
    // --- Case Dimensions ---
    case_width   = 160; // Total width (mm)
    case_depth   = 90;  // Total depth (mm)
    case_height  = 34;  // Back height (mm)
    front_h      = 14;  // Front lip height (mm)
    wall_thick   = 2.5; // Sturdy 2.5mm walls
    post_d       = 7.0; // Screw post outer diameter
    post_h       = 10.0;// Clean 10mm height (fits standard M3 screws)
    screw_hole_d = 3.0; // M3 screw hole
    
    // --- Layout Adjustments ---
    side_margin  = 10.0; // Margin from outer edge
    switch_size  = 14.2; // Cherry/Outemu cutout (mm)
    switch_dist  = 24.0; // Button spacing
    knob_hole_d  = 7.2;  // KY-040 rotary encoder shaft (mm)
    
    // --- Big Screen (2.8" - 3.2" Display) ---
    screen_w     = 75.0; // Display window width (mm)
    screen_h     = 56.0; // Display window height (mm)
    
    
    // ==========================================================
    // USB-C PILL-SHAPED CUTOUT MODULE
    // ==========================================================
    module usbc_cutout() {
        translate([case_width/2, case_depth - wall_thick - 5, 6.5])
        rotate([-90, 0, 0])
        hull() {
            translate([-3.2, 0, 0]) cylinder(r=3.2, h=wall_thick + 10);
            translate([ 3.2, 0, 0]) cylinder(r=3.2, h=wall_thick + 10);
        }
    }
    
    // ==========================================================
    // 1. TOP SHELL MODULE
    // ==========================================================
    module top_shell() {
        corner_offset = wall_thick + post_d/2 + 1;
        
        difference() {
            union() {
                // Outer Wedge Body
                difference() {
                    polyhedron(
                        points = [
                            [0, 0, 0], [case_width, 0, 0], [case_width, case_depth, 0], [0, case_depth, 0],
                            [0, 0, front_h], [case_width, 0, front_h], [case_width, case_depth, case_height], [0, case_depth, case_height]
                        ],
                        faces = [
                            [0,1,2,3], [4,5,1,0], [5,6,2,1], [6,7,3,2], [7,4,0,3], [7,6,5,4]
                        ]
                    );
                    
                    // Hollow Interior Cavity
                    translate([wall_thick, wall_thick, -1])
                    polyhedron(
                        points = [
                            [0, 0, 0], [case_width-2*wall_thick, 0, 0], [case_width-2*wall_thick, case_depth-2*wall_thick, 0], [0, case_depth-2*wall_thick, 0],
                            [0, 0, front_h-wall_thick], [case_width-2*wall_thick, 0, front_h-wall_thick], 
                            [case_width-2*wall_thick, case_depth-2*wall_thick, case_height-wall_thick], [0, case_depth-2*wall_thick, case_height-wall_thick]
                        ],
                        faces = [
                            [0,1,2,3], [4,5,1,0], [5,6,2,1], [6,7,3,2], [7,4,0,3], [7,6,5,4]
                        ]
                    );
                }
                
                // 4 Internal Screw Posts (Clean 10mm height, safely below roof)
                translate([corner_offset, corner_offset, 0]) 
                    cylinder(d=post_d, h=post_h);
                translate([case_width - corner_offset, corner_offset, 0]) 
                    cylinder(d=post_d, h=post_h);
                translate([corner_offset, case_depth - corner_offset, 0]) 
                    cylinder(d=post_d, h=post_h);
                translate([case_width - corner_offset, case_depth - corner_offset, 0]) 
                    cylinder(d=post_d, h=post_h);
            }
    
            // Screw Pilot Holes (for M3 screws)
            translate([corner_offset, corner_offset, -1]) 
                cylinder(d=2.8, h=post_h + 2);
            translate([case_width - corner_offset, corner_offset, -1]) 
                cylinder(d=2.8, h=post_h + 2);
            translate([corner_offset, case_depth - corner_offset, -1]) 
                cylinder(d=2.8, h=post_h + 2);
            translate([case_width - corner_offset, case_depth - corner_offset, -1]) 
                cylinder(d=2.8, h=post_h + 2);
    
            // USB-C Pill Cutout
            usbc_cutout();
    
            // Top Face Cutouts (Buttons, Screen, Knob)
            tilt_angle = atan2(case_height - front_h, case_depth);
            translate([0, 0, front_h])
            rotate([tilt_angle, 0, 0]) {
                // Left 3 Buttons
                for (i = [0:2]) {
                    translate([side_margin, 14 + i * switch_dist, -10])
                    cube([switch_size, switch_size, 20]);
                }
                // Screen Window
                translate([case_width/2 - screen_w/2, (case_depth - screen_h)/2 + 2, -10])
                cube([screen_w, screen_h, 20]);
                // Right 2 Buttons
                for (i = [1:2]) {
                    translate([case_width - side_margin - switch_size, 14 + i * switch_dist, -10])
                    cube([switch_size, switch_size, 20]);
                }
                // Knob
                translate([case_width - side_margin - switch_size/2, 14 + switch_size/2, -10])
                cylinder(d=knob_hole_d, h=20);
            }
        }
    }
    
    // ==========================================================
    // 2. BOTTOM BASE PLATE MODULE
    // ==========================================================
    module bottom_plate() {
        plate_thick = 2.0;
        lip_thick   = 1.5;
        corner_offset = wall_thick + post_d/2 + 1;
        
        difference() {
            union() {
                // Main Base Plate
                cube([case_width, case_depth, plate_thick]);
                
                // Alignment Inner Lip
    		translate([wall_thick + 0.3, wall_thick + 0.3, plate_thick])
                difference() {
                    cube([case_width - 2*wall_thick - 0.6, case_depth - 2*wall_thick - 0.6, lip_thick]);
                    translate([1.5, 1.5, -0.5])
                    cube([case_width - 2*wall_thick - 3.6, case_depth - 2*wall_thick - 3.6, lip_thick + 1]);
                }
            }
            
            // 4 Countersunk Screw Holes for M3
            translate([corner_offset, corner_offset, -1]) {
                cylinder(d=screw_hole_d + 0.5, h=plate_thick + 4);
                cylinder(d1=6.5, d2=screw_hole_d + 0.5, h=1.8); // Countersink
            }
            translate([case_width - corner_offset, corner_offset, -1]) {
                cylinder(d=screw_hole_d + 0.5, h=plate_thick + 4);
                cylinder(d1=6.5, d2=screw_hole_d + 0.5, h=1.8);
            }
            translate([corner_offset, case_depth - corner_offset, -1]) {
                cylinder(d=screw_hole_d + 0.5, h=plate_thick + 4);
                cylinder(d1=6.5, d2=screw_hole_d + 0.5, h=1.8);
            }
            translate([case_width - corner_offset, case_depth - corner_offset, -1]) {
                cylinder(d=screw_hole_d + 0.5, h=plate_thick + 4);
                cylinder(d1=6.5, d2=screw_hole_d + 0.5, h=1.8);
            }
        }
    }

    // ==========================================================
    // RENDER OUTPUT CONTROLLER
    // ==========================================================
    if (part_to_render == "both") {
        top_shell();
        translate([0, case_depth + 15, 0]) bottom_plate();
    } else if (part_to_render == "top") {
        top_shell();
    } else if (part_to_render == "bottom") {
        bottom_plate();
    } else if (part_to_render == "assembled") {
        top_shell();
        translate([0, 0, -2]) color([0.3, 0.3, 0.3]) bottom_plate();
    }