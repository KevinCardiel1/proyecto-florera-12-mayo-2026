Actua como un administrador de base de datos: proyecto floreria, que entidades se necesitan para su gestion
## Entidades para el Sistema de Gestión de una Florería


Aquí te presento las entidades principales organizadas por módulo:

---

<img width="1440" height="772" alt="image" src="https://github.com/user-attachments/assets/21649e28-7df1-4bac-b056-178db60473e0" />


### 🌸 Núcleo del Negocio

**1. Producto (Flor / Arreglo)**
- id_producto, nombre, descripción, tipo (flor suelta / arreglo / planta), precio_venta, stock, imagen, activo

**2. Categoría**
- id_categoria, nombre, descripción *(Rosas, Orquídeas, Arreglos fúnebres, Centros de mesa...)*

**3. Proveedor**
- id_proveedor, nombre, contacto, teléfono, email, dirección, tiempo_entrega

**4. Inventario / Lote**
- id_lote, id_producto, id_proveedor, cantidad, fecha_entrada, fecha_vencimiento, costo_unitario

---

### 👥 Clientes y Ventas

**5. Cliente**
- id_cliente, nombre, apellido, teléfono, email, dirección, fecha_registro, notas *(alergias, preferencias)*

**6. Pedido**
- id_pedido, id_cliente, fecha_pedido, fecha_entrega, estado, tipo *(mostrador / domicilio / evento)*, total, notas

**7. Detalle\_Pedido**
- id_detalle, id_pedido, id_producto, cantidad, precio_unitario, personalización

**8. Pago**
- id_pago, id_pedido, monto, metodo *(efectivo, tarjeta, transferencia)*, fecha, referencia

---

### 🚚 Logística

**9. Envío / Entrega**
- id_envio, id_pedido, id_repartidor, dirección_destino, fecha_programada, hora_entrega, estado, costo

**10. Empleado / Repartidor**
- id_empleado, nombre, rol *(vendedor, florista, repartidor)*, teléfono, turno

---

### 📅 Eventos y Fidelización

**11. Evento**
- id_evento, id_cliente, nombre_evento, tipo *(boda, graduación, funeral)*, fecha, presupuesto, descripción

**12. Ocasión / Fecha especial**
- id_ocasion, id_cliente, descripcion *(aniversario, cumpleaños)*, fecha → para recordatorios automáticos

---

### 📊 Relaciones clave

```
Proveedor ──< Lote >── Producto ──< Detalle_Pedido >── Pedido ──< Pago
                                                           │
                                                       Envío >── Empleado
                                                           │
                                                        Cliente ──< Evento
```

---

¿Quieres que proceda a generar el **DDL (CREATE TABLE)**, el **diagrama ER**, o el **modelo relacional completo** para alguna base de datos específica como MySQL, PostgreSQL o SQL Server?

las entidades con sus atributos y tipo en forma de tabla para cada una de las entidades

<img width="726" height="394" alt="image" src="https://github.com/user-attachments/assets/5d5df27e-a6cc-4d64-885b-8f5d0b4b59e6" />
<img width="721" height="339" alt="image" src="https://github.com/user-attachments/assets/285d531c-fc11-493e-8af1-5218669a343e" />
<img width="660" height="339" alt="image" src="https://github.com/user-attachments/assets/c5e4ad5c-8a7c-428c-b1c7-3a9ee06b0c07" />
<img width="768" height="336" alt="image" src="https://github.com/user-attachments/assets/41623406-33f0-4cce-ab00-86c2c4698579" />
<img width="450" height="458" alt="image" src="https://github.com/user-attachments/assets/d8ff92b8-43b1-4730-bbe7-f9b804e005aa" />
<img width="480" height="409" alt="image" src="https://github.com/user-attachments/assets/2eb07ba1-3337-42fa-bb53-ad7a154f8e17" />
<img width="389" height="364" alt="image" src="https://github.com/user-attachments/assets/4749ac57-5b83-45a9-b346-6bbccf427bf3" />
<img width="394" height="359" alt="image" src="https://github.com/user-attachments/assets/001b4aaf-a89e-4c42-8ee7-d58a63660d50" />

