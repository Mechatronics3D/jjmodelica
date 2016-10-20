# jJModelica
jJModelica includes:

   - Jupyter
   - JModelica
   - CasADi
   - Ipopt
   - ASL
   - BLAS
   - LAPACK
   - MUMPS
   - METIS

## Usage
You can run the container using this command:

`docker run -p 8888:8888 mechatronics3d/jjmodelica`

Then go to this address on your browser:

`http://localhost:8888/`

# Example
To run the first example, open a new Jupyter Notebook for Python 2 and enter:

`%matplotlib inline`

 `from pyjmi.examples import VDP_sim`
 
 `VDP_sim.run_demo()`
