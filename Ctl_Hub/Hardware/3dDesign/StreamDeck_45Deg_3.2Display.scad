// ==========================================================
// DIY STREAM DECK LITE - 45° CONSOLE (PARAMETRIC & MODULAR)
// - Tactile Button Sockets (12x12mm) with Screw-Down Rear Retainer Brackets
// - Kailh Choc Switch compatibility toggle
// - Reinforced Display Standoffs with Gussets + Recessed Bezel Pocket
// - Dual-Orientation KY-040 Encoder Anti-Twist Ribs (Horizontal for DuPont clearance)
// - Modular 45° Stand Feet: 100% Flat 3D Printing with ZERO Slicer Supports!
// - Flat Bottom Base Plate with Flush Countersunk Screws & Cable Notch
// ==========================================================
$fn = 35; // Smoothness

// --- CHOOSE WHAT TO RENDER ---
// "both"      : Full printable kit laid out flat on build plate (Zero supports!)
// "top"       : Top shell only
// "bottom"    : Flat bottom plate only
// "feet"      : The 2 modular 45° stand feet only
// "brackets"  : The 2 tactile button rear retainer plates only
// "assembled" : Realistic 45° desk console assembled preview
part_to_render = "both"; 

// --- Enclosure Dimensions ---
tilt_angle        = 45.0; // Console desk angle (degrees)
case_width        = 152.0;// Outer width (mm)
case_depth        = 92.0; // Outer depth (mm)
box_h             = 26.0; // Enclosure height (mm) - provides headroom for 90° headers & DuPont cables
wall_thick        = 2.5;  // Perimeter wall thickness (mm)
front_wall_thick  = 2.2;  // Front faceplate thickness (mm)
cable_notch_d     = 5.0;  // Rear cable exit notch diameter (mm)

// --- Assembly & Fasteners ---
post_d            = 7.5;  // Corner assembly boss diameter (mm)
corner_offset     = 6.0;  // Corner screw center offset (mm)
screw_hole_d      = 3.0;  // M3 clearance hole diameter (mm)
pilot_hole_d      = 2.8;  // M3 thread pilot hole diameter (mm)

// --- Button Configuration ---
// "tactile" : 12x12mm tactile push button switches with square keycaps (hand-wired)
// "choc"    : 14x14mm mechanical keyboard switches (Kailh Choc / Cherry MX snap-in)
switch_type       = "tactile"; 

// 12x12mm Tactile Switch Parameters
tact_body_w       = 15.2; // 15.0mm measured + 0.2mm tolerance // Tactile switch body width/depth + 0.4mm tolerance (mm)
tact_body_h       = 4.2;  // Tactile switch body depth/cavity (mm)
tact_cap_w        = 14.6; // Keycap clearance cutout on front face // Front face cutout for keycap clearance (mm)
tact_cradle_wall  = 1.5;  // Socket wall thickness (mm)
tact_wire_slot_w  = 5.5;  // Wire exit slot width (mm)

// Kailh Choc Parameters (used when switch_type == "choc")
choc_cutout       = 14.0; // 14.0mm standard cutout (mm)
choc_thick        = 1.3;  // Plate thickness for Choc clips (mm)
side_margin       = 8.0;  // Margin from left/right edge (mm)

// --- Global Key & Knob Coordinates ---
left_kx           = 15.5; // Calibrated 15mm key center (8mm margin + 15mm/2)
right_kx          = case_width - 15.5; // Calibrated right key center

knob_y            = 15.0; // Rotary knob center Y (mm)
key1_y            = 36.0; // Key Row 1 center Y (mm)
key2_y            = 55.0; // Key Row 2 center Y (mm)
key3_y            = 74.0; // Key Row 3 center Y (mm)

// Retainer bracket screw boss locations (between keys)
boss1_y           = (key1_y + key2_y) / 2; // 45.5 mm
boss2_y           = (key2_y + key3_y) / 2; // 64.5 mm
key_boss_d        = 5.5;  // Retainer boss outer diameter (mm)
key_boss_screw_d  = 2.4;  // Pilot hole for M2.5 / M3 retainer screws (mm)

// --- Rotary Encoder (KY-040) Parameters ---
knob_hole_d       = 7.2;  // KY-040 threaded collar hole + tolerance (mm)
knob_pcb_w        = 19.4; // Measured 19.0mm + 0.4mm tolerance // PCB width between anti-twist ribs (mm)
knob_rib_h        = 3.5;  // Anti-twist rib height (mm)
// "horizontal": Header pins point inward toward case center (clears Key 1 and DuPont cables!)
// "vertical"  : Header pins point along Y
knob_orientation  = "horizontal"; 

// --- 3.2" SPI Display Specs & Chin Offset ---
screen_w          = 65.2; // Viewable window width (AA = 64.80mm + 0.4mm clearance) // 3.2" Viewable active window width (mm)
screen_h          = 49.0; // Viewable window height (AA = 48.60mm + 0.4mm clearance) // 3.2" Viewable active window height (mm)
screen_pocket_w   = 78.5; // Bezel pocket width (BL frame = 77.70mm + 0.8mm clearance) // Recessed pocket for white LCD bezel width (mm)
screen_pocket_h   = 55.6; // Bezel pocket height (BL frame = 55.04mm + 0.5mm clearance) // Recessed pocket for white LCD bezel height (mm)
screen_pocket_d   = 2.2;  // Bezel pocket depth (glass assembly = 2.90mm)  // Recessed pocket depth (mm)
disp_hole_x       = 83.30; // Exact datasheet pitch (89.30 - 2*3.0) // Horizontal distance between M2 holes (mm)
disp_hole_y       = 49.04; // Exact datasheet pitch (55.04 - 2*3.0) // Vertical distance between M2 holes (mm)
disp_post_d       = 6.5;  // Reinforced standoff outer diameter (mm)
disp_post_h       = 3.0;  // Standoff height from ceiling (clears 2.9mm glass)  // Standoff height from ceiling (mm)
disp_screw_d      = 2.4;  // Pilot hole for M2.5/M3 screws (PCB holes are ø3.20mm)  // Pilot hole for M2 screws (mm)
disp_chin_offset  = 2.95; // Exact datasheet chin offset (44.65 - 41.70 = 2.95mm)  // Horizontal chin offset (mm)

// --- Modular 45° Stand Feet Specs ---
foot_w            = 12.0; // Foot thickness (mm)
foot_x_left       = 14.0; // Left foot X position (mm)
foot_x_right      = case_width - 14.0 - foot_w; // Right foot X position (mm)
foot_hole_y1      = 22.0; // Front mounting screw Y (mm)
foot_hole_y2      = case_depth - 22.0; // Rear mounting screw Y (mm)
fillet_r          = 8.0;  // Rounded corner radius on desk contact point (mm)

// --- Perfboard Specs (Horizontal 9x7 cm) ---
perf_w            = 90.0; // Board width (mm)
perf_l            = 70.0; // Board length (mm)
perf_hole_x       = 86.0; // Distance between M2 corner holes (mm)
perf_hole_y       = 66.0; // Distance between M2 corner holes (mm)
perf_post_d       = 4.5;  // Standoff outer diameter (mm)
perf_post_h       = 2.5;  // Standoff height (mm)
perf_screw_d      = 1.8;  // Pilot hole for M2 screws (mm)

// Ceiling Z level inside cavity
ceiling_z = box_h - front_wall_thick;

// ==========================================================
// HELPER MODULES
// ==========================================================

// Solid Corner Boss fused to walls and ceiling
module corner_boss(x, y, h) {
    hull() {
        translate([x, y, 0]) cylinder(d=post_d, h=h + 0.1);
        cx = (x < case_width/2) ? wall_thick : case_width - wall_thick;
        cy = (y < case_depth/2) ? wall_thick : case_depth - wall_thick;
        translate([min(x, cx), min(y, cy), 0]) 
            cube([abs(x - cx) + 0.1, abs(y - cy) + 0.1, h + 0.1]);
    }
}

// Reinforced Display Standoff with 4 Radial Gusset Ribs
module reinforced_disp_post(px, py, h, d) {
    translate([px, py, ceiling_z - h]) cylinder(d=d, h=h + 0.1);
    translate([px - d/2 - 2.5, py - 0.9, ceiling_z - h]) cube([d + 5.0, 1.8, h + 0.1]);
    translate([px - 0.9, py - d/2 - 2.5, ceiling_z - h]) cube([1.8, d + 5.0, h + 0.1]);
}

// Tactile Switch Socket Cradle (hanging from ceiling)
module tactile_cradle(cx, cy, wire_dir_x) {
    cw = tact_body_w + 2*tact_cradle_wall;
    ch = tact_body_w + 2*tact_cradle_wall;
    corner_notch = 4.5;
    difference() {
        // Outer socket body
        translate([cx - cw/2, cy - ch/2, ceiling_z - tact_body_h])
            cube([cw, ch, tact_body_h + 0.1]);
            
        // Inner pocket for 12x12mm switch base
        translate([cx - tact_body_w/2, cy - tact_body_w/2, ceiling_z - tact_body_h - 0.1])
            cube([tact_body_w, tact_body_w, tact_body_h + 0.2]);
            
        // Corner 1: Inner-lower corner notch (for solder joint & wires)
        c1_x = (wire_dir_x > 0) ? (cx + tact_body_w/2 - corner_notch + 0.5) : (cx - cw/2 - 0.5);
        translate([c1_x, cy - ch/2 - 0.5, ceiling_z - tact_body_h - 0.1])
            cube([corner_notch + tact_cradle_wall, corner_notch + 0.5, tact_body_h + 0.2]);

        // Corner 2: Inner-upper corner notch (for solder joint & wires)
        translate([c1_x, cy + ch/2 - corner_notch, ceiling_z - tact_body_h - 0.1])
            cube([corner_notch + tact_cradle_wall, corner_notch + 0.5, tact_body_h + 0.2]);
    }
}

// ==========================================================
// 1. TOP SHELL MODULE
// ==========================================================
module top_shell() {
    screen_cx = case_width/2;
    screen_cy = case_depth/2;
    pcb_cx    = screen_cx - disp_chin_offset;

    difference() {
        union() {
            // Main Hollow Box Body
            difference() {
                cube([case_width, case_depth, box_h]);
                translate([wall_thick, wall_thick, -1])
                    cube([case_width - 2*wall_thick, case_depth - 2*wall_thick, ceiling_z + 1]);
            }
            
            // 4 Corner Assembly Bosses
            corner_boss(corner_offset, corner_offset, ceiling_z);
            corner_boss(case_width - corner_offset, corner_offset, ceiling_z);
            corner_boss(corner_offset, case_depth - corner_offset, ceiling_z);
            corner_boss(case_width - corner_offset, case_depth - corner_offset, ceiling_z);

            // 4 Reinforced Display Standoffs with Gussets
            reinforced_disp_post(pcb_cx - disp_hole_x/2, screen_cy - disp_hole_y/2, disp_post_h, disp_post_d);
            reinforced_disp_post(pcb_cx + disp_hole_x/2, screen_cy - disp_hole_y/2, disp_post_h, disp_post_d);
            reinforced_disp_post(pcb_cx - disp_hole_x/2, screen_cy + disp_hole_y/2, disp_post_h, disp_post_d);
            reinforced_disp_post(pcb_cx + disp_hole_x/2, screen_cy + disp_hole_y/2, disp_post_h, disp_post_d);

            // Lateral Display PCB Alignment Guide Rails
            translate([pcb_cx - 89.6/2 - 1.5, screen_cy - 18, ceiling_z - disp_post_h - 1.5])
                cube([1.5, 36, disp_post_h + 1.5]);
            translate([pcb_cx + 89.6/2,       screen_cy - 18, ceiling_z - disp_post_h - 1.5])
                cube([1.5, 36, disp_post_h + 1.5]);

            // Rotary Encoder Reinforced Cradle & Anti-Twist Guide Walls
            if (knob_orientation == "horizontal") {
                // Left knob cradle (open towards +X) - 25.5mm PCB length (exact KY-040 25x19mm)
                translate([left_kx, knob_y, ceiling_z - 1.5]) cylinder(d=14.0, h=1.5 + 0.1);
                translate([left_kx - 11.5, knob_y - knob_pcb_w/2 - 1.5, ceiling_z - knob_rib_h]) cube([27.0, 1.5, knob_rib_h + 0.1]);
                translate([left_kx - 11.5, knob_y + knob_pcb_w/2,       ceiling_z - knob_rib_h]) cube([27.0, 1.5, knob_rib_h + 0.1]);
                translate([left_kx - 11.5, knob_y - knob_pcb_w/2,       ceiling_z - knob_rib_h]) cube([1.5, knob_pcb_w, knob_rib_h + 0.1]);

                // Right knob cradle (open towards -X) - 25.5mm PCB length (exact KY-040 25x19mm)
                translate([right_kx, knob_y, ceiling_z - 1.5]) cylinder(d=14.0, h=1.5 + 0.1);
                translate([right_kx - 15.5, knob_y - knob_pcb_w/2 - 1.5, ceiling_z - knob_rib_h]) cube([27.0, 1.5, knob_rib_h + 0.1]);
                translate([right_kx - 15.5, knob_y + knob_pcb_w/2,       ceiling_z - knob_rib_h]) cube([27.0, 1.5, knob_rib_h + 0.1]);
                translate([right_kx + 10.0, knob_y - knob_pcb_w/2,       ceiling_z - knob_rib_h]) cube([1.5, knob_pcb_w, knob_rib_h + 0.1]);
            } else {
                // Vertical ribs
                for (kx = [left_kx, right_kx]) {
                    translate([kx - knob_pcb_w/2 - 1.5, knob_y - 11, ceiling_z - knob_rib_h]) cube([1.5, 22, knob_rib_h]);
                    translate([kx + knob_pcb_w/2,       knob_y - 11, ceiling_z - knob_rib_h]) cube([1.5, 22, knob_rib_h]);
                }
            }

            // Tactile Button Sockets & Retainer Screw Bosses
            if (switch_type == "tactile") {
                for (ky = [key1_y, key2_y, key3_y]) {
                    tactile_cradle(left_kx,  ky, 1);
                    tactile_cradle(right_kx, ky, -1);
                }
                // Retainer bracket screw bosses between keys
                for (kx = [left_kx, right_kx]) {
                    for (by = [boss1_y, boss2_y]) {
                        translate([kx, by, ceiling_z - tact_body_h])
                            cylinder(d=key_boss_d, h=tact_body_h);
                    }
                }
            }
        }

        // Corner M3 Screw Pilot Holes (10mm deep)
        translate([corner_offset, corner_offset, -1]) cylinder(d=pilot_hole_d, h=10);
        translate([case_width - corner_offset, corner_offset, -1]) cylinder(d=pilot_hole_d, h=10);
        translate([corner_offset, case_depth - corner_offset, -1]) cylinder(d=pilot_hole_d, h=10);
        translate([case_width - corner_offset, case_depth - corner_offset, -1]) cylinder(d=pilot_hole_d, h=10);

        // Retainer bracket screw pilot holes
        if (switch_type == "tactile") {
            for (kx = [left_kx, right_kx]) {
                for (by = [boss1_y, boss2_y]) {
                    translate([kx, by, ceiling_z - tact_body_h - 0.1])
                        cylinder(d=key_boss_screw_d, h=tact_body_h + 0.2);
                }
            }
        }

        // Display standoff mounting pilot holes
        for (dx = [-disp_hole_x/2, disp_hole_x/2]) {
            for (dy = [-disp_hole_y/2, disp_hole_y/2]) {
                translate([pcb_cx + dx, screen_cy + dy, ceiling_z - disp_post_h - 0.1])
                    cylinder(d=disp_screw_d, h=disp_post_h + 1.0);
            }
        }

        // Stepped Bezel Pocket (recessed pocket for white LCD frame)
        translate([screen_cx - screen_pocket_w/2, screen_cy - screen_pocket_h/2, ceiling_z - screen_pocket_d])
            cube([screen_pocket_w, screen_pocket_h, screen_pocket_d + 1]);

        // 3.2" Screen Active Window Cutout
        translate([screen_cx - screen_w/2, screen_cy - screen_h/2, -1])
            cube([screen_w, screen_h, box_h + 2]);

        // Rotary Encoder Shaft Cutouts
        translate([left_kx,  knob_y, -1]) cylinder(d=knob_hole_d, h=box_h + 2);
        translate([right_kx, knob_y, -1]) cylinder(d=knob_hole_d, h=box_h + 2);

        // Button Cutouts on Front Face
        if (switch_type == "tactile") {
            for (ky = [key1_y, key2_y, key3_y]) {
                translate([left_kx  - tact_cap_w/2, ky - tact_cap_w/2, -1]) cube([tact_cap_w, tact_cap_w, box_h + 2]);
                translate([right_kx - tact_cap_w/2, ky - tact_cap_w/2, -1]) cube([tact_cap_w, tact_cap_w, box_h + 2]);
            }
        } else {
            for (ky = [key1_y, key2_y, key3_y]) {
                translate([left_kx  - choc_cutout/2, ky - choc_cutout/2, -1]) cube([choc_cutout, choc_cutout, box_h + 2]);
                translate([right_kx - choc_cutout/2, ky - choc_cutout/2, -1]) cube([choc_cutout, choc_cutout, box_h + 2]);
            }
        }
    }
}

// ==========================================================
// 2. MODULAR 45° STAND FOOT (Prints Flat, Zero Slicer Supports!)
// ==========================================================
module stand_foot() {
    difference() {
        linear_extrude(foot_w) {
            difference() {
                hull() {
                    translate([0, -2]) square([4, 2]);
                    translate([case_depth - 4, -2]) square([4, 2]);
                    translate([case_depth/2, -case_depth/2 + fillet_r]) circle(r=fillet_r);
                }
                // Smooth hollow cutout
                offset(r=5.0) offset(delta=-5.0)
                polygon(points=[
                    [16.0, -5.0],
                    [case_depth - 16.0, -5.0],
                    [case_depth/2, -case_depth/2 + 18.0]
                ]);
            }
        }
        // Top mounting pilot holes (M3 thread, 12mm deep)
        for (hx = [foot_hole_y1, foot_hole_y2]) {
            translate([hx, 0.1, foot_w/2])
                rotate([90, 0, 0])
                cylinder(d=pilot_hole_d, h=14);
        }
    }
}

// ==========================================================
// 3. FLAT BOTTOM BASE PLATE (100% Flat Bed Contact, Zero Supports!)
// ==========================================================
module bottom_plate() {
    plate_thick = 2.2;
    lip_thick   = 1.5;
    perf_cx     = case_width / 2;
    perf_cy     = case_depth / 2;

    difference() {
        union() {
            // Flat base plate
            cube([case_width, case_depth, plate_thick]);
            
            // Perimeter alignment inner lip
            translate([wall_thick + 0.3, wall_thick + 0.3, plate_thick])
            difference() {
                cube([case_width - 2*wall_thick - 0.6, case_depth - 2*wall_thick - 0.6, lip_thick]);
                translate([1.5, 1.5, -0.5])
                cube([case_width - 2*wall_thick - 3.6, case_depth - 2*wall_thick - 3.6, lip_thick + 1]);
            }
            
            // 4 M2 Perfboard standoffs
            translate([perf_cx - perf_hole_x/2, perf_cy - perf_hole_y/2, plate_thick]) cylinder(d=perf_post_d, h=perf_post_h);
            translate([perf_cx + perf_hole_x/2, perf_cy - perf_hole_y/2, plate_thick]) cylinder(d=perf_post_d, h=perf_post_h);
            translate([perf_cx - perf_hole_x/2, perf_cy + perf_hole_y/2, plate_thick]) cylinder(d=perf_post_d, h=perf_post_h);
            translate([perf_cx + perf_hole_x/2, perf_cy + perf_hole_y/2, plate_thick]) cylinder(d=perf_post_d, h=perf_post_h);
        }

        // Cable U-notch on rear rim
        translate([case_width/2, case_depth - wall_thick - 5, plate_thick + lip_thick])
        rotate([-90, 0, 0])
        hull() {
            translate([0, -cable_notch_d/2, 0]) cylinder(d=cable_notch_d, h=wall_thick + 10);
            translate([0, 5.0, 0])              cylinder(d=cable_notch_d, h=wall_thick + 10);
        }

        // 4 M2 Blind Perfboard holes (remain inside standoffs, DO NOT pierce bottom plate!)
        translate([perf_cx - perf_hole_x/2, perf_cy - perf_hole_y/2, plate_thick]) cylinder(d=perf_screw_d, h=perf_post_h + 0.2);
        translate([perf_cx + perf_hole_x/2, perf_cy - perf_hole_y/2, plate_thick]) cylinder(d=perf_screw_d, h=perf_post_h + 0.2);
        translate([perf_cx - perf_hole_x/2, perf_cy + perf_hole_y/2, plate_thick]) cylinder(d=perf_screw_d, h=perf_post_h + 0.2);
        translate([perf_cx + perf_hole_x/2, perf_cy + perf_hole_y/2, plate_thick]) cylinder(d=perf_screw_d, h=perf_post_h + 0.2);

        // 4 Corner M3 countersunk holes
        for (pos = [[corner_offset, corner_offset],
                    [case_width - corner_offset, corner_offset],
                    [corner_offset, case_depth - corner_offset],
                    [case_width - corner_offset, case_depth - corner_offset]]) {
            translate([pos[0], pos[1], -1]) {
                cylinder(d=screw_hole_d + 0.5, h=plate_thick + 4);
                cylinder(d1=6.5, d2=screw_hole_d + 0.5, h=1.8);
            }
        }

        // 4 M3 Countersunk holes for Modular Stand Feet (screwed from inside base plate)
        for (sx = [foot_x_left, foot_x_right]) {
            for (hy = [foot_hole_y1, foot_hole_y2]) {
                translate([sx + foot_w/2, hy, -1]) {
                    cylinder(d=screw_hole_d + 0.4, h=plate_thick + 2);
                    // Countersink on top inside floor so screw heads are 100% flush
                    translate([0, 0, plate_thick - 0.9]) cylinder(d1=screw_hole_d + 0.4, d2=6.8, h=2.0);
                }
            }
        }

        // Clean solid underside - no deep trenches cutting through the plate!
    }
}

// ==========================================================
// 4. TACTILE BUTTON REAR RETAINER BRACKET
// ==========================================================
module key_retainer_bracket() {
    cw = tact_body_w + 2*tact_cradle_wall;
    bar_w = cw;
    bar_l = (key3_y - key1_y) + tact_body_w; // Spans all 3 keys (~50.4mm)
    bar_thick = 2.0;

    difference() {
        translate([-bar_w/2, key1_y - tact_body_w/2, 0])
            cube([bar_w, bar_l, bar_thick]);

        // Screw holes matching boss1 and boss2
        translate([0, boss1_y, -0.5]) cylinder(d=3.0, h=bar_thick + 1);
        translate([0, boss2_y, -0.5]) cylinder(d=3.0, h=bar_thick + 1);

        // Countersunk screw head seats
        translate([0, boss1_y, bar_thick - 0.9]) cylinder(d1=3.0, d2=5.8, h=1.0);
        translate([0, boss2_y, bar_thick - 0.9]) cylinder(d1=3.0, d2=5.8, h=1.0);

        // Relief grooves over switch bodies for wire solder joints
        for (ky = [key1_y, key2_y, key3_y]) {
            translate([-bar_w/2 - 0.1, ky - 3.0, bar_thick - 0.7])
                cube([bar_w + 0.2, 6.0, 1.0]);
        }
    }
}

// ==========================================================
// RENDER CONTROLLER
// ==========================================================
bracket_w = tact_body_w + 2*tact_cradle_wall;
bracket_l = (key3_y - key1_y) + tact_body_w;
bracket_y_offset = key1_y - tact_body_w/2;

if (part_to_render == "both") {
    // 1. Top Shell (printed face down at Z=0)
    top_shell();
    
    // 2. Flat Bottom Plate (printed flat at Z=0)
    translate([0, case_depth + 12, 0]) bottom_plate();
    
    // 3. Stand Foot 1 (printed lying flat on side at Z=0)
    translate([case_width + 10, 0, 0])
        rotate([0, 0, 90])
        stand_foot();
        
    // 4. Stand Foot 2 (printed lying flat on side at Z=0)
    translate([case_width + 10, case_depth + 10, 0])
        rotate([0, 0, 90])
        stand_foot();
        
    // 5. Left Key Retainer Bracket (printed flat at Z=0)
    translate([case_width + 10 + case_depth/2 + 10 + bracket_w/2, 15 - bracket_y_offset, 0])
        key_retainer_bracket();
        
    // 6. Right Key Retainer Bracket (printed flat at Z=0)
    translate([case_width + 10 + case_depth/2 + 10 + bracket_w/2, 15 + bracket_l + 12 - bracket_y_offset, 0])
        key_retainer_bracket();
} else if (part_to_render == "top") {
    top_shell();
} else if (part_to_render == "bottom") {
    bottom_plate();
} else if (part_to_render == "feet") {
    translate([0, case_depth/2, 0]) stand_foot();
    translate([0, case_depth + 10, 0]) stand_foot();
} else if (part_to_render == "brackets") {
    translate([bracket_w/2, -bracket_y_offset, 0]) key_retainer_bracket();
    translate([bracket_w/2 + 25, -bracket_y_offset, 0]) key_retainer_bracket();
} else if (part_to_render == "assembled") {
    // 45° Realistic Assembled Desktop Console
    rotate([tilt_angle, 0, 0]) {
        top_shell();
        translate([0, 0, -2.2]) color([0.35, 0.35, 0.35]) bottom_plate();
        // Stand feet attached underneath
        for (sx = [foot_x_left, foot_x_right]) {
            translate([sx, 0, -2.2])
            rotate([90, 0, 90])
            color([0.2, 0.2, 0.2])
            stand_foot();
        }
        // Retainer brackets mounted behind keys
        if (switch_type == "tactile") {
            for (kx = [left_kx, right_kx]) {
                translate([kx, 0, ceiling_z - tact_body_h - 2.0])
                    color([0.8, 0.2, 0.2])
                    key_retainer_bracket();
            }
        }
    }
}
