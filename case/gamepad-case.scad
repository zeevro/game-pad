$fn = 50;

left = 0 + 69.75;
top = 0 + 33;

width = 217.5 - left;
height = 146.75 - top;

top_step = 110 - left;
lower_top = 51.25 - top;

pcb_corners = [
    [0, 0],
    [top_step, 0],
    [top_step, lower_top],
    [width, lower_top],
    [width, height],
    [0, height],
];

screws = [
    [96-left, 60-top],            // top left
    [96-left, 137.25-top],        // bottom left
    [200-left, 137.25-top],       // bottom right
    [198.3232-left, 70.5104-top], // top right
    [142, 5],
];

function sx(l, w) = l + w/2;

switches = [
    [[0,    1], [1.75, 1], [2.75, 1], [3.75, 1], [4.75, 1], [5.75, 1], [6.75, 1]], // Top row
    [[0,  1.5], [1.75, 1], [2.75, 1], [3.75, 1], [4.75, 1], [5.75, 1], [6.75, 1]], // 2nd row
    [[0, 1.25], [1.75, 1], [2.75, 1], [3.75, 1], [4.75, 1], [5.75, 1], [6.75, 1]], // 3rd row
    [[0, 1.75], [1.75, 1], [2.75, 1], [3.75, 1], [4.75, 1], [5.75, 1], [6.75, 1]], // 4th row
    [[0, 1.25],                          [1.5, 6.25]                            ], // Bottom row
];

case_wall_thickness = 2;
case_floor_thickness = 1;
case_gap = 2;

pcb_thickness = 1.6;
pcb_floor = case_floor_thickness + case_gap;
pcb_ceiling = pcb_floor + pcb_thickness;

plate_thickness = 1.5;
plate_spacing = 0 + 5;
plate_gap = plate_spacing - plate_thickness;
plate_floor = pcb_ceiling + plate_gap;
plate_ceiling = plate_floor + plate_thickness;

inserts_height = 3;
inserts_od = 5;
inserts_buffer_height = plate_gap - inserts_height;

screw_head_diameter = 6;
screw_head_thickness = 1;
screw_shaft_d = 3;
screw_length = 9;

switch_cutout_width = 14;
switch_cutout_height = 14;

stab_cutout_width = 8;
stab_cutout_height = 15;
stab_cutout_vertical_offset = 0.62;
stab_space_horizontal_offset = 50;

controller_left = 0 + 0;
controller_top = 0 + 0.376;
controller_width = 0 + 33.3;
controller_height = 0 + 18;
controller_thickness = 0 + 1.6;
reset_button = [36.75, 4.25];

usb_width = 9;
usb_thickness = 3.3;

reset_hole_d = 2;
led_hole_d = 2;

cutout_clearance = 0.25;

mirror([0, 1, 0]) {
    // Screws
    color("#444")
        translate([0, 0, plate_ceiling])
        // mirror([0, 0, 1])
            for (pos = screws)
                translate(pos) {
                    cylinder(h = screw_head_thickness, d = screw_head_diameter);
                    translate([0, 0, -screw_length]) cylinder(h = screw_length, d = screw_shaft_d);
                }

    // Plate
    color("lightblue", 0.8) {
        translate([0, 0, plate_floor]) {
            linear_extrude(plate_thickness)
                difference() {
                    offset(r = case_wall_thickness) square([width, height]);

                    // Screw holes
                    for (pos = screws) translate(pos) circle(d = screw_shaft_d+cutout_clearance);

                    // Cutouts for switches and stabilizers
                    for (row = [0:len(switches)-1], col = [0:len(switches[row])-1]) {
                        switch = switches[row][col];
                        pos = switch[0];
                        width = switch[1];
                        x = (pos + width / 2) * 19.05;
                        y = lower_top + 0.2 + (row + 0.5) * 19.05;
                        translate([x, y]) {
                            square([switch_cutout_width+cutout_clearance, switch_cutout_height+cutout_clearance], center = true);
                            if (width == 6.25) {
                                translate([-stab_space_horizontal_offset, -stab_cutout_vertical_offset])
                                    square([stab_cutout_width+cutout_clearance, stab_cutout_height+cutout_clearance], center = true);

                                translate([stab_space_horizontal_offset, -stab_cutout_vertical_offset])
                                    square([stab_cutout_width+cutout_clearance, stab_cutout_height+cutout_clearance], center = true);
                            }
                        }
                    }

                    // Cutout for reset button
                    translate(reset_button) circle(d = reset_hole_d+cutout_clearance);

                    // Cutouts for controller LEDs
                    translate([controller_left+8.5, controller_top+3]) circle(d = led_hole_d+cutout_clearance);
                    translate([controller_left+8.5, controller_top+controller_height-3]) circle(d = led_hole_d+cutout_clearance);
                }

            // Screw posts
            for (pos = screws) {
                translate([pos[0], pos[1], -plate_gap])
                    linear_extrude(plate_gap)
                        difference() {
                            circle(d = screw_shaft_d+2);
                            circle(d = screw_shaft_d+cutout_clearance);
                        }
            }

            // Metal insert holders
            *for (pos = screws) {
                translate([pos[0], pos[1], -inserts_buffer_height])
                    linear_extrude(inserts_buffer_height)
                        circle(d = inserts_od);

                translate([pos[0], pos[1], -plate_gap])
                    linear_extrude(plate_gap)
                        difference() {
                            circle(d = inserts_od + 1);
                            circle(d = inserts_od - 0.5);
                        }
            }
        }

        // Walls
        difference() {
            translate([0, 0, plate_floor-2])
                linear_extrude(2)
                    difference() {
                        translate([cutout_clearance, cutout_clearance])
                            square([width-cutout_clearance*2, height-cutout_clearance*2]);
                        translate([2, 2])
                            square([width-4, height-4]);
                    }

            // Cutout for USB
            translate([0, controller_height/2, pcb_ceiling+usb_thickness/2])
                rotate([90, 0, 90])
                    linear_extrude(case_wall_thickness*4, center = true)
                        offset(r = 1)
                            square([usb_width-1, usb_thickness-1], center = true);

            // Cutout for power switch
            translate([controller_width+15, 0, plate_ceiling/2])
                rotate([90, 0, 0])
                    linear_extrude(case_wall_thickness*4, center = true)
                        square([6, 3], center = true);
        }
    }

    // PCB
    color("darkgreen", 0.4)
        translate([0, 0, pcb_floor])
            linear_extrude(pcb_thickness)
                difference() {
                    polygon(pcb_corners);
                    for (pos = screws) translate(pos) circle(d = 3);
                }

    // Case
    color("lightgray", 0.8) {
        // Floor
        linear_extrude(case_floor_thickness)
            difference() {
                square([width, height]);
                for (pos = screws) translate(pos) circle(d = inserts_od-0.5);
            }

        // Walls
        difference() {
            linear_extrude(plate_floor)
                difference() {
                    offset(r = case_wall_thickness) square([width, height]);
                    square([width, height]);
                }

            // Cutout for USB
            translate([0, controller_height/2, pcb_ceiling+usb_thickness/2])
                rotate([90, 0, 90])
                    linear_extrude(case_wall_thickness*4, center = true)
                        offset(r = 1)
                            square([usb_width-1, usb_thickness-1], center = true);

            // Cutout for power switch
            translate([controller_width+15, 0, plate_ceiling/2])
                rotate([90, 0, 0])
                    linear_extrude(case_wall_thickness*4, center = true)
                        square([6, 3], center = true);
        }

        // Screw posts
        *for (pos = screws) {
            translate([pos[0], pos[1], case_floor_thickness])
                cylinder(h = case_gap, d = 4+cutout_clearance);
        }

        // Metal insert holders
        for (pos = screws) {
            translate([pos[0], pos[1], 0])
                linear_extrude(inserts_height)
                    difference() {
                        circle(d = inserts_od+1);
                        circle(d = inserts_od-0.5);
                    }
        }
    }
}