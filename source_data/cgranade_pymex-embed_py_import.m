%%
% py_import.m: Wrapper for the "import" C function.
%%
% (c) 2013 Christopher E. Granade (cgranade@cgranade.com).
%    
% This file is a part of the pymex-embed project.
% Licensed under the AGPL version 3.
%%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU Affero General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Affero General Public License for more details.
%
% You should have received a copy of the GNU Affero General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%

function [varargout] = py_import(name)
    py_obj = pymex_fns(py_function_t.IMPORT, name);
    if nargout == 1
        varargout{1} = py_obj;
    else
        % If there's a dot, we need to import until we get the "root" object,
        % then put that in the caller's namespace.
        idxs_dot = strfind(name, '.');
        if ~isempty(idxs_dot)
            root_name = name(1:idxs_dot(1)-1);
            root_obj = py_import(root_name);
            assignin('caller', root_name, root_obj);
        else
            assignin('caller', name, py_obj);
        end
    end
end
