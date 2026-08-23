// ==========================================================
    // DIY STREAM DECK LITE - WITH INTERNAL SOCKETS & SUPPORTS
    // Kailh Choc + KY-040 + ESP32-S3 + Display Support
    // ==========================================================
    $fn = 40; // Circle smoothness
    
    // --- CHOOSE WHAT TO RENDER ---
    // Options: "both" (for 3D printing), "top", "bottom", "assembled"
    part_to_render = "both"; 
    
    // --- Case Dimensions ---
    case_width   = 160; // Total width (mm)
    case_depth   = 90;  // Total depth (mm)
    case_height  = 36;  // Back height (mm)
    front_h      = 18;  // Front lip height (mm)
    wall_thick   = 2.5; // Sturdy 2.5mm perimeter walls
    post_d       = 7.0; // Screw post diameter
    post_h       = 10.0;// 10mm M3 screw posts
    screw_hole_d = 3.0; // M3 screw hole
    
    // --- Component Dimensions ---
    choc_cutout  = 14.0; // Kailh Choc 13.80mm body + 0.2mm tolerance
    choc_thick   = 1.3;  // 1.3mm plate thickness for Choc clips
    switch_dist  = 24.0; // Button spacing
    side_margin  = 10.0; // Margin from outer edge
    knob_hole_d  = 7.2;  // KY-040 rotary encoder shaft (mm)
    screen_w     = 75.0; // Display window width (mm)
    screen_h     = 56.0; // Display window height (mm)
    
    // --- ESP32-S3 Board Socket Dimensions ---
    esp_w        = 27.2; // Board width (mm)
    esp_l        = 38.0; // Board length (mm)
    esp_rail_h   = 4.5;  // Cradle rail height (mm)
    
    // ==========================================================
    // USB-C PILL-SHAPED CUTOUT
    // ==========================================================
    module usbc_cutout() {
        translate([case_width/2, case_depth - wall_thick - 5, 7.5])
        rotate([-90, 0, 0])
        hull() {
            translate([-3.2, 0, 0]) cylinder(r=3.2, h=wall_thick + 10);
            translate([ 3.2, 0, 0]) cylinder(r=3.2, h=wall_thick + 10);
        }
    }
    
    // ==========================================================
    // 1. TOP SHELL WITH INTERNAL SOCKETS
    // ==========================================================
    module top_shell() {
        corner_offset = wall_thick + post_d/2 + 1;
        tilt_angle = atan2(case_height - front_h, case_depth);
        
        difference() {
            union() {
                // Main Outer Body
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
                    
                    // Hollow Interior
                    translate([wall_thick, wall_thick, -1])
                    polyhedron(
                        points = [
                            [0, 0, 0], [case_width-2*wall_thick, 0, 0], [case_width-2*wall_thick, case_depth-2*wall_thick, 0], [0, case_depth-2*wall_thick, 0],
                            [0, 0, front_h-choc_thick], [case_width-2*wall_thick, 0, front_h-choc_thick], 
                            [case_width-2*wall_thick, case_depth-2*wall_thick, case_height-choc_thick], [0, case_depth-2*wall_thick, case_height-choc_thick]
                        ],
                        faces = [
                            [0,1,2,3], [4,5,1,0], [5,6,2,1], [6,7,3,2], [7,4,0,3], [7,6,5,4]
                        ]
                    );
                }
                
                // 4 Internal M3 Screw Posts
                translate([corner_offset, corner_offset, 0]) 
                    cylinder(d=post_d, h=post_h);
                translate([case_width - corner_offset, corner_offset, 0]) 
                    cylinder(d=post_d, h=post_h);
                translate([corner_offset, case_depth - corner_offset, 0]) 
                    cylinder(d=post_d, h=post_h);
                translate([case_width - corner_offset, case_depth - corner_offset, 0]) 
                    cylinder(d=post_d, h=post_h);
    
                // Underside Display Retention Brackets & KY-040 Anti-Twist Ribs
                translate([0, 0, front_h])
                rotate([tilt_angle, 0, 0]) {
                    
                    // --- Display Corner L-Brackets ---
                    disp_x = case_width/2 - screen_w/2;
                    disp_y = (case_depth - screen_h)/2 + 2;
                    bracket_w = 4.0;
                    bracket_h = 3.0;
                    
                    // Top-Left & Top-Right Brackets
                    translate([disp_x - 2, disp_y + screen_h + 1, -bracket_h]) cube([8, bracket_w, bracket_h]);
                    translate([disp_x + screen_w - 6, disp_y + screen_h + 1, -bracket_h]) cube([8, bracket_w, bracket_h]);
                    
                    // Bottom-Left & Bottom-Right Brackets
                    translate([disp_x - 2, disp_y - bracket_w - 1, -bracket_h]) cube([8, bracket_w, bracket_h]);
                    translate([disp_x + screen_w - 6, disp_y - bracket_w - 1, -bracket_h]) cube([8, bracket_w, bracket_h]);
    
                    // --- KY-040 Anti-Twist Guide Ribs ---
                    knob_center_x = case_width - side_margin - choc_cutout/2;
                    knob_center_y = 14 + choc_cutout/2;
                    // Left & Right retention walls for KY-040 PCB (18.6mm inner width)
                    translate([knob_center_x - 9.3 - 1.5, knob_center_y - 8, -2.5]) cube([1.5, 22, 2.5]);
                    translate([knob_center_x + 9.3,       knob_center_y - 8, -2.5]) cube([1.5, 22, 2.5]);
                }
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
    
            // USB-C Cutout
            usbc_cutout();
    
            // Top Panel Cutouts
            translate([0, 0, front_h])
            rotate([tilt_angle, 0, 0]) {
                // Left 3 Kailh Choc Cutouts
                for (i = [0:2]) {
                    translate([side_margin, 14 + i * switch_dist, -10])
                    cube([choc_cutout, choc_cutout, 20]);
                }
                // Screen Window
                translate([case_width/2 - screen_w/2, (case_depth - screen_h)/2 + 2, -10])
                cube([screen_w, screen_h, 20]);
                // Right 2 Kailh Choc Cutouts
                for (i = [1:2]) {
                    translate([case_width - side_margin - choc_cutout, 14 + i * switch_dist, -10])
                    cube([choc_cutout, choc_cutout, 20]);
                }
                // Knob Cutout
                translate([case_width - side_margin - choc_cutout/2, 14 + choc_cutout/2, -10])
                cylinder(d=knob_hole_d, h=20);
            }
        }
    }
    
    // ==========================================================
    // 2. BOTTOM BASE PLATE WITH ESP32-S3 CRADLE
    // ==========================================================
    module bottom_plate() {
        plate_thick = 2.0;
        lip_thick   = 1.5;
        corner_offset = wall_thick + post_d/2 + 1;
        rail_t = 1.6;
        
        // ESP32 cradle positions
        esp_x = case_width/2 - esp_w/2;
        esp_y = case_depth - wall_thick - esp_l;
    
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
                
                // --- ESP32-S3 SLIDE-IN CRADLE ---
                // 1. Riser floor (prevents pins shorting on base)
                translate([esp_x, esp_y, plate_thick]) 
                    cube([esp_w, esp_l, 1.2]);
                // 2. Left guide rail
                translate([esp_x - rail_t, esp_y, plate_thick]) 
                    cube([rail_t, esp_l, esp_rail_h]);
    		// 3. Right guide rail
                translate([esp_x + esp_w, esp_y, plate_thick]) 
                    cube([rail_t, esp_l, esp_rail_h]);
                // 4. Front Backstop (absorbs USB-C insertion push force)
                translate([esp_x - rail_t, esp_y - rail_t, plate_thick]) 
                    cube([esp_w + 2*rail_t, rail_t, esp_rail_h]);
            }
            
            // 4 Countersunk Screw Holes for M3
            translate([corner_offset, corner_offset, -1]) {
                cylinder(d=screw_hole_d + 0.5, h=plate_thick + 4);
                cylinder(d1=6.5, d2=screw_hole_d + 0.5, h=1.8);
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