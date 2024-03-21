extends WeaponFunction

class_name BP2WeaponFunction;

var mag_ammo: int = 12;
var current_ammo: int = mag_ammo;
var bullet_speed: float = 1000;
var pellet_count: int = 5;
var reload_time_per_shell: float = 0.1;
var reloading: bool = false;

var weapon_controller: WeaponController;

@export var bullet: PackedScene;
@export var muzzle_flash: PackedScene;

func _start_shoot(weapon_controller: WeaponController) -> void:
	super._start_shoot(weapon_controller);
	
	reloading = false;
	
	self.weapon_controller = weapon_controller;
	
	var direction = Vector2(cos(weapon_controller.global_rotation), sin(weapon_controller.global_rotation));
	weapon_controller.parent_titan_camera.shake(10, -direction);
		
	var muzzle_flash_instance: GPUParticles2D = muzzle_flash.instantiate();
	weapon_controller.get_tree().current_scene.add_child(muzzle_flash_instance);
	
	muzzle_flash_instance.global_position = weapon_controller.barrel_location.global_position;
	muzzle_flash_instance.global_rotation = weapon_controller.barrel_location.global_rotation;
	
	muzzle_flash_instance.emitting = true;
	
	for i in range(pellet_count):
		var bullet_instance: Bullet = bullet.instantiate();
		weapon_controller.get_tree().current_scene.add_child(bullet_instance);
		
		bullet_instance.global_position = weapon_controller.barrel_location.global_position;
		bullet_instance.global_rotation = weapon_controller.barrel_location.global_rotation;
		
		randomize();
		bullet_instance.velocity = Vector2(bullet_speed, randf_range(-100, 100)).rotated(bullet_instance.global_rotation);
	
	current_ammo -= 1;

func _stop_shoot(weapon_controller: WeaponController) -> void:
	super._stop_shoot(weapon_controller);
	
	self.weapon_controller = weapon_controller;

func _reload(weapon_controller: WeaponController) -> void:
	super._reload(weapon_controller);
	
	reloading = true;
	
	self.weapon_controller = weapon_controller;
	
	add_ammo(weapon_controller);

func add_ammo(weapon_controller: WeaponController) -> void:
	await weapon_controller.get_tree().create_timer(reload_time_per_shell).timeout;
	
	current_ammo += 1;
	
	if(reloading):
		add_ammo(weapon_controller);
	else:
		weapon_controller._on_reload_end();

func _manual_process(delta: float) -> void:
	super._manual_process(delta);
