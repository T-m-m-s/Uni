// ==========================================================
// DIY STREAM DECK LITE - VARIANT 2: 20° TILT (PERFBOARD MOTHERBOARD)
// - 3.2" Display + 6 Kailh Choc Keys + 2 Rotary Knobs
// - 5x7 cm Perfboard Motherboard Standoffs (4x M2 Screws)
// - Predictable USB-C Port Alignment at Z = 8.0mm
// - 20° Sleek Desk Riser Skids + Direct-Access Corner M3 Screws
// - 100% Solid Front Panel with Blind Internal Display Standoffs
// ==========================================================
$fn = 40; // Circle smoothness

// --- CHOOSE WHAT TO RENDER ---
// Options: "both" (for 3D printing), "top", "bottom", "assembled" (shows desk stance)
part_to_render = "both"; 

// --- Incline & Box Dimensions ---
tilt_angle   = 20.0;// Sleek 20° angle
case_width   = 175; // Total width (mm) - adjusted for 3.2" display
case_depth   = 105; // Total depth (mm) - balanced for 4 rows
box_h        = 22;  // Slim uniform box thickness (mm)
wall_thick   = 2.5; // Perimeter wall thickness (mm)

// --- Assembly & Fasteners ---
post_d       = 7.0; // Corner assembly post diameter
post_h       = 12.0;// M3 screw post height
screw_hole_d = 3.0; // M3 screw hole

// --- Component Dimensions ---
choc_cutout  = 14.0; // Kailh Choc 13.80mm body + 0.2mm tolerance
choc_thick   = 1.3;  // 1.3mm plate thickness for Choc clips
side_margin  = 13.0; // Margin from outer left/right edge
knob_hole_d  = 7.2;  // KY-040 threaded collar + 0.2mm tolerance

// --- Vertical Spacing (4 Rows: 3 Keys on top + 1 Knob on bottom) ---
knob_y       = 17.0; // Bottom knob center Y (mm)
key1_y       = 40.0; // Key Row 1 center Y (mm)
key2_y       = 62.5; // Key Row 2 center Y (mm)
key3_y       = 85.0; // Key Row 3 center Y (mm)

// --- 3.2" SPI Display Specs & Chin Offset ---
screen_w     = 65.0; // 3.2" Landscape viewable window width (mm)
screen_h     = 49.0; // 3.2" Landscape viewable height (mm)
disp_hole_x  = 84.0; // Horizontal distance between M2 holes (mm)
disp_hole_y  = 50.0; // Vertical distance between M2 holes (mm)
disp_post_d  = 4.4;  // Standoff diameter (mm)
disp_post_h  = 3.5;  // Standoff height (mm)
disp_screw_d = 1.8;  // Pilot hole for M2 screws
disp_chin_offset = 4.0; // 4.0mm horizontal chin compensation

// --- Standard 5x7 cm Perfboard Mounting Specs ---
perf_w       = 50.0; // Standard 5x7cm board width (mm)
perf_l       = 70.0; // Standard 5x7cm board length (mm)
perf_hole_x  = 46.0; // Horizontal distance between M2 corner holes (mm)
perf_hole_y  = 66.0; // Vertical distance between M2 corner holes (mm)
perf_post_d  = 4.4;  // Standoff outer diameter (mm)
perf_post_h  = 2.5;  // Standoff height (clears solder joints underneath)
perf_screw_d = 1.8;  // Pilot hole for M2 screws (mm)


// ==========================================================
// USB-C PILL CUTOUT MODULE (Predictable Height)
// ==========================================================
module usbc_cutout() {
    // Calculated height: plate (2.0) + standoff (2.5) + perfboard (1.6) + port center (1.9) = 8.0mm
    translate([case_width/2, case_depth - wall_thick - 5, 8.0])
    rotate([-90, 0, 0])
    hull() {
        translate([-6.5, 0, 0]) cylinder(r=3.5, h=wall_thick + 10);
        translate([ 6.5, 0, 0]) cylinder(r=3.5, h=wall_thick + 10);
    }
}

// ==========================================================
// 1. SLIM TOP SHELL (3.2" Screen + 6 Keys + 2 Knobs)
// ==========================================================
module top_shell() {
    corner_offset = wall_thick + post_d/2 + 1;
    screen_cx = case_width/2;
    screen_cy = case_depth/2;
    pcb_cx    = screen_cx - disp_chin_offset;
    
    // Left & Right X coordinates
    left_x   = side_margin;
    right_x  = case_width - side_margin - choc_cutout;
    left_kx  = side_margin + choc_cutout/2;
    right_kx = case_width - side_margin - choc_cutout/2;

    ceiling_z = box_h - choc_thick;

    difference() {
        union() {
            // Step 1: Hollow Box Outer Body
            difference() {
                cube([case_width, case_depth, box_h]);
                
                // Hollow Cavity
                translate([wall_thick, wall_thick, -1])
                cube([case_width - 2*wall_thick, case_depth - 2*wall_thick, ceiling_z + 1]);
            }
            
            // Step 2: 4 Corner Assembly Posts
            translate([corner_offset, corner_offset, 0]) cylinder(d=post_d, h=post_h);
            translate([case_width - corner_offset, corner_offset, 0]) cylinder(d=post_d, h=post_h);
            translate([corner_offset, case_depth - corner_offset, 0]) cylinder(d=post_d, h=post_h);
            translate([case_width - corner_offset, case_depth - corner_offset, 0]) cylinder(d=post_d, h=post_h);

            // Step 3: 4 Internal Display Standoffs (Hanging from ceiling)
            translate([pcb_cx - disp_hole_x/2, screen_cy - disp_hole_y/2, ceiling_z - disp_post_h]) 
                cylinder(d=disp_post_d, h=disp_post_h);
            translate([pcb_cx + disp_hole_x/2, screen_cy - disp_hole_y/2, ceiling_z - disp_post_h]) 
                cylinder(d=disp_post_d, h=disp_post_h);
            translate([pcb_cx - disp_hole_x/2, screen_cy + disp_hole_y/2, ceiling_z - disp_post_h]) 
                cylinder(d=disp_post_d, h=disp_post_h);
            translate([pcb_cx + disp_hole_x/2, screen_cy + disp_hole_y/2, ceiling_z - disp_post_h]) 
                cylinder(d=disp_post_d, h=disp_post_h);

            // Step 4: Dual KY-040 Anti-Twist Guide Ribs
            // Left Knob Ribs
            translate([left_kx - 9.3 - 1.5, knob_y - 11, ceiling_z - 2.5]) cube([1.5, 22, 2.5]);
            translate([left_kx + 9.3,       knob_y - 11, ceiling_z - 2.5]) cube([1.5, 22, 2.5]);
            // Right Knob Ribs
            translate([right_kx - 9.3 - 1.5, knob_y - 11, ceiling_z - 2.5]) cube([1.5, 22, 2.5]);
            translate([right_kx + 9.3,       knob_y - 11, ceiling_z - 2.5]) cube([1.5, 22, 2.5]);
        }

        // --- SUBTRACTIONS ---
        // Corner M3 Screw Pilot Holes
        translate([corner_offset, corner_offset, -1]) cylinder(d=2.8, h=post_h + 2);
        translate([case_width - corner_offset, corner_offset, -1]) cylinder(d=2.8, h=post_h + 2);
        translate([corner_offset, case_depth - corner_offset, -1]) cylinder(d=2.8, h=post_h + 2);
        translate([case_width - corner_offset, case_depth - corner_offset, -1]) cylinder(d=2.8, h=post_h + 2);

        // Blind M2 Display Screw Pilot Holes (stops 0.8mm before front face)
        translate([pcb_cx - disp_hole_x/2, screen_cy - disp_hole_y/2, ceiling_z - disp_post_h - 0.1]) 
            cylinder(d=disp_screw_d, h=2.8);
        translate([pcb_cx + disp_hole_x/2, screen_cy - disp_hole_y/2, ceiling_z - disp_post_h - 0.1]) 
            cylinder(d=disp_screw_d, h=2.8);
        translate([pcb_cx - disp_hole_x/2, screen_cy + disp_hole_y/2, ceiling_z - disp_post_h - 0.1]) 
            cylinder(d=disp_screw_d, h=2.8);
        translate([pcb_cx + disp_hole_x/2, screen_cy + disp_hole_y/2, ceiling_z - disp_post_h - 0.1]) 
            cylinder(d=disp_screw_d, h=2.8);

        // USB-C Cutout in back wall
        usbc_cutout();

        // 3.2" Screen Window Cutout
        translate([screen_cx - screen_w/2, screen_cy - screen_h/2, -1])
        cube([screen_w, screen_h, box_h + 2]);

        // Left 3 Kailh Choc Cutouts
        translate([left_x, key1_y - choc_cutout/2, -1]) cube([choc_cutout, choc_cutout, box_h + 2]);
        translate([left_x, key2_y - choc_cutout/2, -1]) cube([choc_cutout, choc_cutout, box_h + 2]);
        translate([left_x, key3_y - choc_cutout/2, -1]) cube([choc_cutout, choc_cutout, box_h + 2]);
        // Left Knob Cutout
        translate([left_kx, knob_y, -1]) cylinder(d=knob_hole_d, h=box_h + 2);

        // Right 3 Kailh Choc Cutouts
        translate([right_x, key1_y - choc_cutout/2, -1]) cube([choc_cutout, choc_cutout, box_h + 2]);
        translate([right_x, key2_y - choc_cutout/2, -1]) cube([choc_cutout, choc_cutout, box_h + 2]);
        translate([right_x, key3_y - choc_cutout/2, -1]) cube([choc_cutout, choc_cutout, box_h + 2]);
        // Right Knob Cutout
        translate([right_kx, knob_y, -1]) cylinder(d=knob_hole_d, h=box_h + 2);
    }
}

// ==========================================================
// 2. BOTTOM BASE PLATE WITH 5x7cm PERFBOARD STANDOFFS
// ==========================================================
module bottom_plate() {
    plate_thick = 2.0;
    lip_thick   = 1.5;
    corner_offset = wall_thick + post_d/2 + 1;
    
    // Perfboard Center Coordinates (Aligned to rear for USB-C)
    perf_cx = case_width / 2;
    perf_cy = case_depth - wall_thick - 1.0 - perf_l/2; // Center Y = 66.5mm
    
    // Riser Feet Dimensions
    foot_w = 18.0;
    foot_l = 30.0;

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
            
            // --- 4 M2 STANDOFFS FOR 5x7cm PERFBOARD ---
            translate([perf_cx - perf_hole_x/2, perf_cy - perf_hole_y/2, plate_thick]) 
                cylinder(d=perf_post_d, h=perf_post_h);
            translate([perf_cx + perf_hole_x/2, perf_cy - perf_hole_y/2, plate_thick]) 
                cylinder(d=perf_post_d, h=perf_post_h);
            translate([perf_cx - perf_hole_x/2, perf_cy + perf_hole_y/2, plate_thick]) 
                cylinder(d=perf_post_d, h=perf_post_h);
            translate([perf_cx + perf_hole_x/2, perf_cy + perf_hole_y/2, plate_thick]) 
                cylinder(d=perf_post_d, h=perf_post_h);

            // --- REAR DESK RISER FEET (Left & Right Skids) ---
            for (fx = [20, case_width - 20 - foot_w]) {
                difference() {
                    translate([fx, case_depth - foot_l, -case_depth * sin(tilt_angle) - 10])
                        cube([foot_w, foot_l, case_depth * sin(tilt_angle) + 10.1]);
                    
                    // Desk cut plane (rotates to match desk angle)
                    rotate([-tilt_angle, 0, 0])
                    translate([fx - 5, -50, -100])
                    cube([foot_w + 10, 300, 100]);
                }
            }
            
            // --- FRONT RESTING LIP (Beveled flat to the desk) ---
            difference() {
                translate([0, 0, -8]) cube([case_width, 10, 8.1]);
                rotate([-tilt_angle, 0, 0])
                translate([-5, -50, -100])
                cube([case_width + 10, 300, 100]);
            }
        }
        
        // --- 4 M2 PILOT HOLES FOR PERFBOARD SCREWS ---
        translate([perf_cx - perf_hole_x/2, perf_cy - perf_hole_y/2, plate_thick - 1]) 
            cylinder(d=perf_screw_d, h=perf_post_h + 2);
        translate([perf_cx + perf_hole_x/2, perf_cy - perf_hole_y/2, plate_thick - 1]) 
            cylinder(d=perf_screw_d, h=perf_post_h + 2);
        translate([perf_cx - perf_hole_x/2, perf_cy + perf_hole_y/2, plate_thick - 1]) 
            cylinder(d=perf_screw_d, h=perf_post_h + 2);
        translate([perf_cx + perf_hole_x/2, perf_cy + perf_hole_y/2, plate_thick - 1]) 
            cylinder(d=perf_screw_d, h=perf_post_h + 2);

        // --- 4 DIRECT FLAT COUNTERSUNK M3 CORNER HOLES ---
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
// RENDER CONTROLLER
// ==========================================================
if (part_to_render == "both") {
    // Top Shell
    top_shell();
    // Bottom Plate (Oriented for clean 3D printing)
    translate([0, case_depth + 15, 0]) bottom_plate();
} else if (part_to_render == "top") {
    top_shell();
} else if (part_to_render == "bottom") {
    bottom_plate();
} else if (part_to_render == "assembled") {
    // Realistic Desk Stance: Front pad & rear feet rest 100% flat on desk!
    rotate([tilt_angle, 0, 0]) {
        top_shell();
        translate([0, 0, -2]) color([0.25, 0.25, 0.25]) bottom_plate();
    }
}