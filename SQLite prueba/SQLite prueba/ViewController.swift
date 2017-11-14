//
//  ViewController.swift
//  SQLite prueba
//
//  Created by 7k on 17/10/17.
//  Copyright © 2017 7k. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController {

    var database: Connection!
    let usuariosTable = Table("usuarios")
    let id = Expression<Int>("id")
    let nombre = Expression<String>("nombre")
    let email = Expression<String>("email")
    
    @IBOutlet var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("usuarios").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database//self se usa cuando se quiere usar un objeto global de la aplicación (self es como this)
            //al database global se le va a asignar el database creado aquí
        } catch {
            print(error)
        }
    }//se ejecuta en cuanto termina de cargar la vista por viewDidLoad

    @IBAction func crearTabla() {
        print("Presionaste Crear tabla")
        
        let createTable = self.usuariosTable.create { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.nombre)
            table.column(self.email, unique: true)
        }
        
        do {
            try self.database.run(createTable)
            print("Tabla creada")
        } catch {
            print(error)
        }
    }
    
    @IBAction func insertarUsuario() {
        print("Presionaste Insertar usuario")
        let alert = UIAlertController(title: "Insertar Usuario", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in tf.placeholder = "Nombre" }
        alert.addTextField { (tf) in tf.placeholder = "Email" }
        let action = UIAlertAction(title: "Guardar", style: .default) { (_) in
            guard let nombre = alert.textFields?.first?.text,
                let email = alert.textFields?.last?.text
                else { return }
            print(nombre)
            print(email)
            
            let insertarUsuarios = self.usuariosTable.insert(self.nombre <- nombre, self.email <- email)
            
            do {
                try self.database.run(insertarUsuarios)
                print("Usuario generado")
            } catch {
                print(error)
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func verUsuarios() {
        print("Presionaste Ver Usuarios")
        
        do {
            let usuarios = try self.database.prepare(self.usuariosTable)
            for usuario in usuarios {
                print("Id: \(usuario[self.id]), Nombre: \(usuario[self.nombre]), Email: \(usuario[self.email])")
            }
        } catch {
            print(error)
        }
    }
    
    @IBAction func actualizarUsuario() {
        print("Presionaste Actualizar usuario")
        let alert = UIAlertController(title: "Actualizar usuarios", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in tf.placeholder = "ID" }
        alert.addTextField { (tf) in tf.placeholder = "Email" }
        let action = UIAlertAction(title: "Actualizar", style: .default) { (_) in
            guard let idString = alert.textFields?.first?.text,
                let id = Int(idString),
                let email = alert.textFields?.last?.text
                else { return }
            print(idString)
            print(email)
            
            let usuario = self.usuariosTable.filter(self.id == id)
            let usuarioActualizado = usuario.update(self.email <- email)
            do {
                try self.database.run(usuarioActualizado)
            } catch {
                print(error)
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func eliminarUsuario() {
        print("Presionaste Eliminar Usuario")
        let alert = UIAlertController(title: "Eliminar usuario", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in tf.placeholder = "ID" }
        let action = UIAlertAction(title: "Eliminar", style: .default) { (_) in
            guard let idString = alert.textFields?.first?.text,
                let id = Int(idString)
                else { return }
            print(idString)
            
            let usuario = self.usuariosTable.filter(self.id == id)
            let usuarioEliminado = usuario.delete()
            do {
                try self.database.run(usuarioEliminado)
            } catch {
                print(error)
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buscarUsuario() {
        var encontrados = 0
        do {
            let usuario = self.usuariosTable.filter(self.email == emailTextField.text!)
            for usuario in try database.prepare(usuario) {
                encontrados += 1
                print("Id: \(usuario[self.id]), Nombre: \(usuario[self.nombre]), Email: \(usuario[self.email])")
            }
        } catch {
            print(error)
        }
        print("Se encontró \(encontrados) usuarios.")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

