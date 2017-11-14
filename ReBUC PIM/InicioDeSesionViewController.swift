//
//  InicioDeSesionViewController.swift
//  ReBUC PIM
//
//  Created by 7k on 19/10/17.
//  Copyright © 2017 Administrador. All rights reserved.
//

import UIKit
import SQLite

class InicioDeSesionViewController: UIViewController {
    //Propiedades de la base de datos
    var database: Connection!
    let usuariosTabla = Table("Usuarios")
    let idUsuarioExp = Expression<Int>("id_usuario")
    let emailExp = Expression<String>("email")
    let contrasenaExp = Expression<String>("Contraseña")
    let idTipoUsuarioExp = Expression<Int>("id_tipo_usuario")
    
    //Tabla de sesión activa
    let sesionTabla = Table("Sesión")
    let idUsuarioSesExp = Expression<Int>("id_usuario")
    let idTipoUsuarioSesExp = Expression<Int>("id_tipo_usuario")
    
    //objetos que se utilizaran en este controlador
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var contrasenaTextField: UITextField!
    
    //Datos de sesión
    var idUsuario: Int = 0
    var idTipoUsuario: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Obtener la ruta del archivo usuarios.sqlite3
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("usuarios").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database//self se usa cuando se quiere usar un objeto global de la aplicación (self es como this)
            //al database global se le va a asignar el database creado aquí
        } catch {
            print(error)
        }
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func ingresar(_ sender: UIButton) {
        do {
            let usuario = self.usuariosTabla.filter(self.emailExp == emailTextField.text! && self.contrasenaExp == contrasenaTextField.text!)
            for usuario in try database.prepare(usuario) {
                print("idUsuario: \(usuario[self.idUsuarioExp]), email: \(usuario[self.emailExp]), idTipoUsuario: \(usuario[self.idTipoUsuarioExp])")
                self.idUsuario = usuario[self.idUsuarioExp]
                self.idTipoUsuario = usuario[self.idTipoUsuarioExp]
            }
        } catch {
            print(error)
        }
        if idUsuario != 0 {
            print("Sesión exitosa")
            //idUsuario = 0
            //Crear la tabla de Usuarios
            let crearTabla = self.sesionTabla.create { (tabla) in
                tabla.column(self.idUsuarioSesExp, primaryKey: true)
                tabla.column(self.idTipoUsuarioSesExp)
            }
            
            do {
                try self.database.run(crearTabla)
                print("Tabla creada")
            } catch {
                print(error)
            }
            
            //Guardar sesión
            let registrarSesion = self.sesionTabla.insert(self.idUsuarioSesExp <- self.idTipoUsuario, self.idTipoUsuarioSesExp <- self.idTipoUsuario)
            
            do {
                try self.database.run(registrarSesion)
                print("Sesion del usuario \(self.idUsuario) guardada")
            } catch {
                print(error)
            }
            
            //Ejecutar segue
            if idTipoUsuario == 1 {
                self.performSegue(withIdentifier: "universitarioSegue", sender: self)
            }
            
        } else {
            print("Error en los datos")
            
            //Ejecutar un alert
            let alert = UIAlertController(title: "Error", message: "Usuario y/o contraseña incorrecta", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (_) in
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "universitarioSegue"{
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
