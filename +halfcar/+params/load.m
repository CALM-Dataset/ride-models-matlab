function P = load(file)
if nargin < 1
    here = fileparts(mfilename('fullpath'));
    file = fullfile(here, '..', '..', 'data', 'halfcar', 'params.json');
end
P = jsondecode(fileread(file));
P.front = derive_axle(P.front);
P.rear = derive_axle(P.rear);
P.m_tot = P.body.m_B + P.front.m_W + P.rear.m_W;
P.L = P.body.l_f + P.body.l_r;
end

function a = derive_axle(a)
z1 = 2 * a.D / (1 + a.A);
d1 = a.A * z1;
a.d1 = d1;
a.z1 = z1;
a.d2 = d1 / 0.25;
a.z2 = z1 / 0.40;
end
