// ==========================================================
// DIY STREAM DECK LITE - 45° CONSOLE (3.5" DISPLAY VARIANT)
// - Solid Corner Screw Bosses fused to walls & ceiling (No floating gaps!)
// - Large 3.5" Color Screen (74mm x 50mm active view window)
// - 6 Kailh Choc Keys + 2 Rotary Encoders (Snug 21mm spacing to screen)
// - Horizontal 9x7 cm Perfboard Standoffs (86x66mm pitch)
// - Lower-Only 0.5cm (5.0mm) U-Notch on Bottom Plate (100% solid top rim)
// - Compact Vertical Right-Triangle L-Stand (Zero protrusion behind box)
// ==========================================================
$fn = 40; // Circle smoothness

// --- CHOOSE WHAT TO RENDER ---
// Options: "both" (for 3D printing), "top", "bottom", "assembled" (shows 45° desk stance)
part_to_render = "both"; 

// --- Narrowed & Compact Dimensions for 3.5" Screen ---
tilt_angle   = 45.0;// Steep 45° console angle
case_width   = 160; // Narrowed width for 3.5" screen (mm)
case_depth   = 92;  // Compact depth (mm) - fits horizontal 9x7cm board
box_h        = 22;  // Slim uniform box thickness (mm)
wall_thick   = 2.5; // Perimeter wall thickness (mm)
cable_notch_d= 5.0; // Exact 0.5cm (5.0mm) diameter cable notch

// --- Assembly & Fasteners ---
post_d        = 7.5; // Corner assembly boss diameter
corner_offset = 6.0; // Corner screw center offset (mm)
screw_hole_d  = 3.0; // M3 clearance hole for bottom plate
pilot_hole_d  = 2.8; // M3 thread bite pilot hole

// --- Component Dimensions ---
choc_cutout  = 14.0; // Kailh Choc 13.80mm body + 0.2mm tolerance
choc_thick   = 1.3;  // 1.3mm plate thickness for Choc clips
side_margin  = 8.0;  // Snug 8mm side margin (brings keys closer to screen)
knob_hole_d  = 7.2;  // KY-040 threaded collar + 0.2mm tolerance

// --- Compact Vertical Spacing (4 Rows: 3 Keys on top + 1 Knob on bottom) ---
knob_y       = 15.0; // Bottom knob center Y (mm)
key1_y       = 36.0; // Key Row 1 center Y (mm)
key2_y       = 55.0; // Key Row 2 center Y (mm)
key3_y       = 74.0; // Key Row 3 center Y (mm)

// --- 3.5" SPI Display Specs & Chin Offset ---
screen_w     = 74.0; // 3.5" Landscape viewable window width (mm)
screen_h     = 50.0; // 3.5" Landscape viewable height (mm)
disp_hole_x  = 90.5; // Horizontal distance between M2 holes (mm)
disp_hole_y  = 55.0; // Vertical distance between M2 holes (mm)
disp_post_d  = 4.4;  // Standoff diameter (mm)
disp_post_h  = 3.5;  // Standoff height (mm)
disp_screw_d = 1.8;  // Pilot hole for M2 screws
disp_chin_offset = 4.0; // 4.0mm horizontal chin compensation

// --- HORIZONTAL 9x7 cm Perfboard Mounting Specs ---
perf_w       = 90.0; // Horizontal board width (mm)
perf_l       = 70.0; // Horizontal board depth (mm)
perf_hole_x  = 86.0; // Horizontal distance between M2 corner holes (mm)
perf_hole_y  = 66.0; // Vertical distance between M2 corner holes (mm)
perf_post_d  = 4.4;  // Standoff outer diameter (mm)
perf_post_h  = 2.5;  // Standoff height (clears solder joints underneath)
perf_screw_d = 1.8;  // Pilot hole for M2 screws (mm)


// ==========================================================
// SOLID CORNER BOSS MODULE (Fused to walls and ceiling)
// ==========================================================
module corner_boss(x, y, ceiling_z) {
    hull() {
        translate([x, y, 0]) cylinder(d=post_d, h=ceiling_z);
        cx = (x < case_width/2) ? 0 : case_width - wall_thick;
        cy = (y < case_depth/2) ? 0 : case_depth - wall_thick;
        translate([min(x, cx), min(y, cy), 0]) 
            cube([abs(x - cx) + 0.1, abs(y - cy) + 0.1, ceiling_z]);
    }
}


// ==========================================================
// 1. SLIM TOP SHELL (3.5" Screen + Solid Corner Bosses)
// ==========================================================
module top_shell() {
    screen_cx = case_width/2;
    screen_cy = case_depth/2;
    pcb_cx    = screen_cx - disp_chin_offset;
    
    left_x   = side_margin;
    right_x  = case_width - side_margin - choc_cutout;
    left_kx  = side_margin + choc_cutout/2;
    right_kx = case_width - side_margin - choc_cutout/2;

    ceiling_z = box_h - choc_thick;

    difference() {
        union() {
            // Step 1: Hollow Box Outer Body (100% solid back, no holes)
            difference() {
                cube([case_width, case_depth, box_h]);
                
                // Hollow Cavity
                translate([wall_thick, wall_thick, -1])
                cube([case_width - 2*wall_thick, case_depth - 2*wall_thick, ceiling_z + 1]);
            }
            
            // Step 2: 4 Solid Corner Bosses (Seamlessly fused to walls & ceiling)
            corner_boss(corner_offset, corner_offset, ceiling_z);
            corner_boss(case_width - corner_offset, corner_offset, ceiling_z);
            corner_boss(corner_offset, case_depth - corner_offset, ceiling_z);
            corner_boss(case_width - corner_offset, case_depth - corner_offset, ceiling_z);

            // Step 3: 4 Internal Display Standoffs for 3.5" Screen (Hanging from ceiling)
            translate([pcb_cx - disp_hole_x/2, screen_cy - disp_hole_y/2, ceiling_z - disp_post_h]) 
                cylinder(d=disp_post_d, h=disp_post_h);
            translate([pcb_cx + disp_hole_x/2, screen_cy - disp_hole_y/2, ceiling_z - disp_post_h]) 
                cylinder(d=disp_post_d, h=disp_post_h);
            translate([pcb_cx - disp_hole_x/2, screen_cy + disp_hole_y/2, ceiling_z - disp_post_h]) 
                cylinder(d=disp_post_d, h=disp_post_h);
            translate([pcb_cx + disp_hole_x/2, screen_cy + disp_hole_y/2, ceiling_z - disp_post_h]) 
                cylinder(d=disp_post_d, h=disp_post_h);

            // Step 4: Dual KY-040 Anti-Twist Guide Ribs
            translate([left_kx - 9.3 - 1.5, knob_y - 11, ceiling_z - 2.5]) cube([1.5, 22, 2.5]);
            translate([left_kx + 9.3,       knob_y - 11, ceiling_z - 2.5]) cube([1.5, 22, 2.5]);
            translate([right_kx - 9.3 - 1.5, knob_y - 11, ceiling_z - 2.5]) cube([1.5, 22, 2.5]);
            translate([right_kx + 9.3,       knob_y - 11, ceiling_z - 2.5]) cube([1.5, 22, 2.5]);
        }

        // Corner M3 Screw Pilot Holes (9mm deep into the boss from rim)
        translate([corner_offset, corner_offset, -1]) cylinder(d=pilot_hole_d, h=10);
        translate([case_width - corner_offset, corner_offset, -1]) cylinder(d=pilot_hole_d, h=10);
        translate([corner_offset, case_depth - corner_offset, -1]) cylinder(d=pilot_hole_d, h=10);
        translate([case_width - corner_offset, case_depth - corner_offset, -1]) cylinder(d=pilot_hole_d, h=10);

        // Blind M2 Display Screw Pilot Holes (stops 0.8mm before front face)
        translate([pcb_cx - disp_hole_x/2, screen_cy - disp_hole_y/2, ceiling_z - disp_post_h - 0.1]) 
            cylinder(d=disp_screw_d, h=2.8);
        translate([pcb_cx + disp_hole_x/2, screen_cy - disp_hole_y/2, ceiling_z - disp_post_h - 0.1]) 
            cylinder(d=disp_screw_d, h=2.8);
        translate([pcb_cx - disp_hole_x/2, screen_cy + disp_hole_y/2, ceiling_z - disp_post_h - 0.1]) 
            cylinder(d=disp_screw_d, h=2.8);
        translate([pcb_cx + disp_hole_x/2, screen_cy + disp_hole_y/2, ceiling_z - disp_post_h - 0.1]) 
            cylinder(d=disp_screw_d, h=2.8);

        // 3.5" Screen Window Cutout
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
// 2. BOTTOM BASE PLATE (With 0.5cm Lower U-Notch)
// ==========================================================
module bottom_plate() {
    plate_thick = 2.0;
    lip_thick   = 1.5;
    
    // Centered Perfboard in X and Y
    perf_cx = case_width / 2;
    perf_cy = case_depth / 2;
    
    // Sled Bracket Dimensions
    sled_w   = 11.0; // Width of each side runner
    fillet_r = 8.0;  // Smooth 8mm radius on desk corner

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
            
            // --- 4 M2 STANDOFFS FOR HORIZONTAL 9x7cm PERFBOARD ---
            translate([perf_cx - perf_hole_x/2, perf_cy - perf_hole_y/2, plate_thick]) 
                cylinder(d=perf_post_d, h=perf_post_h);
            translate([perf_cx + perf_hole_x/2, perf_cy - perf_hole_y/2, plate_thick]) 
                cylinder(d=perf_post_d, h=perf_post_h);
            translate([perf_cx - perf_hole_x/2, perf_cy + perf_hole_y/2, plate_thick]) 
                cylinder(d=perf_post_d, h=perf_post_h);
            translate([perf_cx + perf_hole_x/2, perf_cy + perf_hole_y/2, plate_thick]) 
                cylinder(d=perf_post_d, h=perf_post_h);

            // --- COMPACT VERTICAL L-FRAME SLED RUNNERS (Left & Right) ---
            for (sx = [12, case_width - 12 - sled_w]) {
                translate([sx, 0, 0])
                rotate([90, 0, 90])
                linear_extrude(sled_w)
                difference() {
                    // Outer Compact Right Triangle (Drops straight down at 45°)
                    hull() {
                        translate([0, -2]) square([4, 2]);
                        translate([case_depth - 4, -2]) square([4, 2]);
                        // Rounded bottom desk corner
                        translate([case_depth/2, -case_depth/2 + fillet_r]) 
                            circle(r=fillet_r, $fn=40);
                    }
                    
                    // Smooth Hollow Inner Window
                    offset(r=5.0, $fn=30) offset(delta=-5.0, $fn=30)
                    polygon(points=[
                        [14.0, -4.5],
                        [case_depth - 14.0, -4.5],
                        [case_depth/2, -case_depth/2 + 16.0]
                    ]);
                }
            }
        }
        
        // --- 0.5cm (5.0mm) U-NOTCH ON LOWER PART ONLY ---
        translate([case_width/2, case_depth - wall_thick - 5, plate_thick + lip_thick])
        rotate([-90, 0, 0])
        hull() {
            translate([0, -cable_notch_d/2, 0]) cylinder(d=cable_notch_d, h=wall_thick + 10);
            translate([0, 5.0, 0])              cylinder(d=cable_notch_d, h=wall_thick + 10);
        }

        // --- 4 M2 PILOT HOLES FOR 9x7cm PERFBOARD SCREWS ---
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
    // Realistic 45° Console Desk Stance!
    rotate([tilt_angle, 0, 0]) {
        top_shell();
        translate([0, 0, -2]) color([0.25, 0.25, 0.25]) bottom_plate();
    }
}
