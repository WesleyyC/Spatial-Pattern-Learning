# GraphMatching

To understand different methologies of different neurons, we want to cluster our 3D image data and cluster neuron by their shape first. 

To cluster our image data, we will need to do some graph matching. However, graph matching is a long-known NP problem, so a lot of algorithms are derived to get an approximated solution in a reasonable time. In this project, we mean to use one of this algorithm to help us soleve the neuron clustering problem efficiently.

According to Gold and Rangarajan, a graduated assignment algorithm is developed to solve the problem efficiently and the code here is an attemp to implment and improve their algorithm mentioned in their paper: https://www.cise.ufl.edu/~anand/pdf/pamigm3.pdf
