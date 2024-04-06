
import {BrowserRouter, Route, Link, Routes} from 'react-router-dom';
import Login from "./Bienvenida";
import Areas from "./Areas";
import Programas from "./Programas";
import Alumnos from "./Alumnos";

const Menu = () => {
  
  return (
        
    <BrowserRouter>
    
        <Link to='/' className="navbar-brand">ICP Credentials</Link>
        <Link to='/areas' className="dropdown-item" >Colmenas</Link>
        <Routes>
            <Route path="/" element={<Login />} />
            <Route path="/areas" element={<Colmenas />} />
        </Routes>
    </BrowserRouter>

  )
}



export default Menu

