extends WeaponFunction

class_name R5WeaponFunction;

var mag_ammo: int = 12;
var current_ammo: int = mag_ammo;
var charging: bool = false;
var charge_time: float = 1.5;
var reload_time: float = 2;

var weapon_controller: WeaponController;

@export var muzzle_flash: PackedScene;
@export var railgun_bullet: PackedScene;

func _start_shoot(weapon_controller: WeaponController) -> void:
	super._start_shoot(weapon_controller);
	
	self.weapon_controller = weapon_controller;
	
	charging = true;
	
	await weapon_controller.get_tree().create_timer(charge_time).timeout;
	
	fire(weapon_controller);

func _stop_shoot(weapon_controller: WeaponController) -> void:
	super._stop_shoot(weapon_controller);
	
	charging = false;
	
	self.weapon_controller = weapon_controller;

func _reload(weapon_controller: WeaponController) -> void:
	super._reload(weapon_controller);
	
	self.weapon_controller = weapon_controller;
	
	await weapon_controller.get_tree().create_timer(reload_time).timeout;
	
	current_ammo = mag_ammo;
	
	weapon_controller._on_reload_end();

func _manual_process(delta: float) -> void:
	super._manual_process(delta);

func fire(weapon_controller: WeaponController) -> void:
	if(!charging):
		return;
	
	var direction = Vector2(cos(weapon_controller.global_rotation), sin(weapon_controller.global_rotation));
	weapon_controller.parent_titan_camera.shake(40, -direction);
	
	var muzzle_flash_instance: GPUParticles2D = muzzle_flash.instantiate();
	weapon_controller.get_tree().current_scene.add_child(muzzle_flash_instance);
	
	muzzle_flash_instance.global_position = weapon_controller.barrel_location.global_position;
	muzzle_flash_instance.global_rotation = weapon_controller.barrel_location.global_rotation;
	
	muzzle_flash_instance.emitting = true;
	
	var railgun_bullet_instance: RailgunBullet = railgun_bullet.instantiate();
	weapon_controller.get_tree().current_scene.add_child(railgun_bullet_instance);
	
	var point: Vector2 = weapon_controller.get_node("RayCast2D").get_collision_point();
	if(point != null):
		railgun_bullet_instance.place(weapon_controller.barrel_location.global_position, point, 2.5);
