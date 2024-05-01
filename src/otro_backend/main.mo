import Types "Types";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Cycles "mo:base/ExperimentalCycles";
import Blob "mo:base/Blob";
import Nat "mo:base/Nat";



actor Areas {
	  let ic : Types.IC = actor "aaaaa-aa"; // Management Canister ID

  public func fetchAlumnosData() : async Text {
    // Definir URL
    let url: Text = "https://ingsoftware.uaz.edu.mx/api/alumnos"; //CAMBIAA

    // Definir encabezados HTTP
    let request_headers = [
      { name = "Host"; value = "ingsoftware.uaz.edu.mx:443" },//CAMBIAA
      { name = "User-Agent"; value = "Motoko HTTP Agent" },
    ];

    // Preparar la solicitud HTTP
    let http_request : Types.HttpRequestArgs = {
        url = url;
        max_response_bytes = null;
        headers = request_headers;
        body = null;
        method = #get;
        transform = null;
    };

    // Añadir ciclos para pagar la solicitud HTTP
    Cycles.add(20_949_972_000);//CAMBIAA

    // Realizar la solicitud HTTP y esperar la respuesta
    let http_response : Types.HttpResponsePayload = await ic.http_request(http_request);

    // Decodificar el cuerpo de la respuesta
    let response_body: Blob = Blob.fromArray(http_response.body);
    let decoded_text: Text = switch (Text.decodeUtf8(response_body)) {
      case (null) { "No value returned" };
      case (?text) { text };
    };

    // Retornar el texto decodificado
    return decoded_text;
  };

  public func sendAlumnoData(alumno: Types.Alumno) : async Text {//CAMBIAA
    // Codificar los datos del alumno en formato JSON
    let alumnoJson: Text = encodeAlumnoJson(alumno);//CAMBIAA

    // URL a la que se enviarán los datos
    let url: Text = "https://ingsoftware.uaz.edu.mx/api/alumnos";//CAMBIAA

    // Codificar el cuerpo de la solicitud en bytes
    let bodyBytesBlob = Text.encodeUtf8(alumnoJson);
    let bodyBytes = Blob.toArray(bodyBytesBlob); // Convertir Blob a [Nat8]

    // Preparar los encabezados y el cuerpo de la solicitud HTTP
    let request_headers = [
      { name = "Host"; value = "ingsoftware.uaz.edu.mx:443" },//CAMBIAA
      { name = "Content-Type"; value = "application/json" }
    ];
    let http_request : Types.HttpRequestArgs = {
        url = url;
        max_response_bytes = null;
        headers = request_headers;
        body = ?bodyBytes;
        method = #post;
        transform = null;
    };

    // Añadir ciclos para pagar la solicitud HTTP
    Cycles.add(1_000_000_000_000); // La cantidad específica necesitará ser ajustada según la documentación


    // Realizar la solicitud HTTP POST y esperar la respuesta
    let http_response : Types.HttpResponsePayload = await ic.http_request(http_request);

    // Decodificar y retornar la respuesta
    let response_body: Blob = Blob.fromArray(http_response.body);
    let decoded_text: Text = switch (Text.decodeUtf8(response_body)) {
      case (null) { "No value returned" };
      case (?text) { text };
    };

    return decoded_text;
  };

  private func encodeAlumnoJson(alumno: Types.Alumno) : Text {//CAMBIAA
    // Construyendo la cadena JSON manualmente
    "{ \"apellido_materno\": \"" # alumno.apellido_materno #
    "\", \"apellido_paterno\": \"" # alumno.apellido_paterno #
    "\", \"carrera\": \"" # alumno.carrera #
    "\", \"fecha_nacimiento\": \"" # alumno.fecha_nacimiento #
    "\", \"nombre\": \"" # alumno.nombre #
    "\", \"semestre\": " # Nat.toText(alumno.semestre) #
    " }"
  }

  // Puedes añadir aquí más funciones según sea necesario.









  type Area = {
		nombre: Text;
	};

  type areaID = Nat32;
	stable var areaID: areaID = 0;

	let listaAreas = HashMap.HashMap<Text, Area>(0, Text.equal, Text.hash);

	private func generaAreaID() : Nat32 {
		areaID += 1;
		return areaID;
	};
	
	public query ({caller}) func whoami() : async Principal {
		return caller;
	};

	public shared (msg) func crearArea(nombre: Text) : async () {
		let area = {nombre=nombre};

		listaAreas.put(Nat32.toText(generaAreaID()), area);
		Debug.print("Nueva área creada ID: " # Nat32.toText(areaID));
		return ();
	};

	public query func obtieneAreas () : async [(Text, Area)] {
		let areaIter : Iter.Iter<(Text, Area)> = listaAreas.entries();
		let areaArray : [(Text, Area)] = Iter.toArray(areaIter);
		Debug.print("Areas ");

		return areaArray;
	};

	public query func obtieneArea (id: Text) : async ?Area {
		let area: ?Area = listaAreas.get(id);
		return area;
	};

	public shared (msg) func actualizarArea (id: Text, nombre: Text) : async Bool {
		let area: ?Area = listaAreas.get(id);

		switch (area) {
			case (null) {
				return false;
			};
			case (?areaActual) {
				let nuevaArea: Area = {nombre=nombre};
				listaAreas.put(id, nuevaArea);
				Debug.print("Area actualizada: " # id);
				return true;
			};
		};

	};

	public func eliminarArea (id: Text) : async Bool {
		let area : ?Area = listaAreas.get(id);
		switch (area) {
			case (null) {
				return false;
			};
			case (_) {
				ignore listaAreas.remove(id);
				Debug.print("Área eliminadaD: " # id);
				return true;
			};
		};
	};


};
